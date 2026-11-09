import Foundation
import AVFoundation
import MediaPlayer
import UIKit
import Capacitor

/*
 Lecteur audio natif d'Effem (iPhone).
 Le son des radios et des podcasts est joué par AVPlayer et non plus par la page web : c'est la seule façon
 pour que l'écoute continue écran éteint, avec les commandes de l'écran verrouillé et du centre de contrôle.
 La page garde toute la logique (favoris, pause « son coupé », reconnexion…) et reçoit ici les mêmes
 événements qu'un élément <audio> : playing, waiting, pause, ended, error, timeupdate, durationchange,
 loadedmetadata, plus mutechange (pause/lecture depuis l'écran verrouillé), track (radio suivante/précédente)
 et alarm (réveil). Le lecteur sait aussi se débrouiller seul quand la page est endormie :
 pause = son coupé, reprise, radio suivante, reconnexion, minuteur, réveil, fin d'appel.
*/
@objc(EffemPlayerPlugin)
public class EffemPlayerPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "EffemPlayerPlugin"
    public let jsName = "EffemPlayer"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "load", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "play", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "pause", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stop", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setMuted", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "seek", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setInfo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setQueue", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sleep", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "armAlarm", returnType: CAPPluginReturnPromise)
    ]

    private let player = AVPlayer()
    private var url: String = ""
    private var live = true
    private var wantPlaying = false          // la personne veut entendre le son (pas en pause, pas arrêté)
    private var muted = false
    private var keepMin: Double = 15         // durée pendant laquelle le direct reste connecté en pause
    private var startAt: Double = 0
    private var timeObs: Any?
    private var itemObs: [NSKeyValueObservation] = []
    private var rateObs: NSKeyValueObservation?
    private var muteTimer: Timer?
    private var sleepTimer: Timer?
    private var alarmTimer: Timer?
    private var retryTimer: Timer?
    private var stallTimer: Timer?
    private var retryN = 0
    private var hadPlayed = false
    private var wasAudibleBeforeInterruption = false
    private var interrupted = false          // une autre app (vidéo avec du son, appel…) a pris le son
    private var guardTimer: Timer?
    private var info: [String: Any] = [:]
    private var artwork: MPMediaItemArtwork?
    private var artworkKey = ""
    private var queue: [[String: String]] = []
    private var keepAlive: AVAudioPlayer?

    override public func load() {
        let s = AVAudioSession.sharedInstance()
        try? s.setCategory(.playback, mode: .default, options: [])
        player.automaticallyWaitsToMinimizeStalling = true
        NotificationCenter.default.addObserver(self, selector: #selector(interruption(_:)), name: AVAudioSession.interruptionNotification, object: s)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaReset(_:)), name: AVAudioSession.mediaServicesWereResetNotification, object: s)
        rateObs = player.observe(\.timeControlStatus, options: [.new]) { [weak self] p, _ in
            DispatchQueue.main.async { self?.statusChanged() }
        }
        timeObs = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: .main) { [weak self] _ in
            self?.emit("timeupdate")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(routeChanged(_:)), name: AVAudioSession.routeChangeNotification, object: s)
        NotificationCenter.default.addObserver(self, selector: #selector(wentBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cameBack), name: UIApplication.didBecomeActiveNotification, object: nil)
        DispatchQueue.main.async {
            self.setupRemote()
            // Garde-fou : tant qu'on veut entendre la radio et qu'aucune autre app n'a pris le son, on relance si l'iPhone l'a coupée
            self.guardTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [weak self] _ in self?.keepPlaying() }
        }
    }

    private var quietChecks = 0

    private func keepPlaying() {
        // Une autre app a pris le son (YouTube, Instagram… dès leur ouverture) mais ne joue rien d'audible :
        // au bout de 2 vérifications (≈ 8 s) on reprend la radio. Si elle lance ensuite une vidéo avec du son, elle reprendra la main.
        if interrupted, wasAudibleBeforeInterruption {
            if AVAudioSession.sharedInstance().isOtherAudioPlaying { quietChecks = 0; return }
            quietChecks += 1
            if quietChecks >= 2 {
                quietChecks = 0
                interrupted = false; wasAudibleBeforeInterruption = false
                wantPlaying = true; activate()
                if live { open(url) }
                player.play()
            }
            return
        }
        quietChecks = 0
        guard wantPlaying, !interrupted, player.currentItem != nil, player.timeControlStatus == .paused, retryTimer == nil else { return }
        activate()
        if live, player.currentItem?.status == .failed { open(url) }
        player.play()
    }

    @objc private func wentBackground() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { self.keepPlaying() }
    }

    @objc private func cameBack() {
        // Retour dans Effem : si une autre app avait pris le son sans le rendre, on reprend
        if interrupted, wasAudibleBeforeInterruption, !AVAudioSession.sharedInstance().isOtherAudioPlaying {
            interrupted = false; wasAudibleBeforeInterruption = false
            wantPlaying = true; activate()
            if live { open(url) }
            player.play()
        }
    }

    // Écouteurs ou casque débranchés : on s'arrête (règle d'Apple), sans repartir tout seul sur le haut-parleur
    @objc private func routeChanged(_ n: Notification) {
        guard let raw = n.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: raw), reason == .oldDeviceUnavailable else { return }
        DispatchQueue.main.async {
            guard self.wantPlaying, !self.muted else { return }
            if self.live, self.keepMin > 0 { self.applyMute(true, notify: true) }
            else { self.wantPlaying = false; self.player.pause(); self.emit("pause") }
        }
    }

    // MARK: - Commandes venant de la page

    @objc func load(_ call: CAPPluginCall) {
        let u = call.getString("url") ?? ""
        live = call.getBool("live") ?? true
        startAt = call.getDouble("startAt") ?? 0
        DispatchQueue.main.async {
            self.cancelRetry()
            self.hadPlayed = false
            self.open(u)
            call.resolve()
        }
    }

    @objc func play(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.wantPlaying = true
            self.activate()
            if self.player.currentItem == nil, !self.url.isEmpty { self.open(self.url) }
            self.player.play()
            self.updateNowPlaying()
            call.resolve()
        }
    }

    @objc func pause(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.wantPlaying = false
            self.cancelRetry()
            self.player.pause()
            self.updateNowPlaying()
            call.resolve()
        }
    }

    @objc func stop(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.stopAll()
            call.resolve()
        }
    }

    @objc func setMuted(_ call: CAPPluginCall) {
        let m = call.getBool("muted") ?? false
        if let k = call.getDouble("keepMin") { keepMin = k }
        DispatchQueue.main.async {
            self.applyMute(m, notify: false)
            call.resolve()
        }
    }

    @objc func seek(_ call: CAPPluginCall) {
        let t = call.getDouble("t") ?? 0
        DispatchQueue.main.async {
            self.player.seek(to: CMTime(seconds: max(0, t), preferredTimescale: 600)) { _ in
                self.emit("timeupdate"); self.updateNowPlaying()
            }
            call.resolve()
        }
    }

    @objc func setInfo(_ call: CAPPluginCall) {
        var i: [String: Any] = [:]
        i["title"] = call.getString("title") ?? "Effem"
        i["artist"] = call.getString("artist") ?? ""
        i["album"] = call.getString("album") ?? ""
        let art = call.getString("artwork") ?? ""
        DispatchQueue.main.async {
            self.info = i
            self.loadArtwork(art)
            self.updateNowPlaying()
            call.resolve()
        }
    }

    @objc func setQueue(_ call: CAPPluginCall) {
        let items = call.getArray("items", JSObject.self) ?? []
        DispatchQueue.main.async {
            self.queue = items.map { o in
                ["url": (o["url"] as? String) ?? "", "title": (o["title"] as? String) ?? "", "artwork": (o["artwork"] as? String) ?? ""]
            }.filter { !($0["url"] ?? "").isEmpty }
            call.resolve()
        }
    }

    @objc func sleep(_ call: CAPPluginCall) {
        let min = call.getDouble("min") ?? 0
        DispatchQueue.main.async {
            self.sleepTimer?.invalidate(); self.sleepTimer = nil
            if min > 0 {
                self.sleepTimer = Timer.scheduledTimer(withTimeInterval: min * 60, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    self.stopAll(); self.emit("pause")
                }
            }
            call.resolve()
        }
    }

    // Réveil : l'app reste éveillée avec un son silencieux tant qu'aucune radio ne joue, puis lance la radio à l'heure dite.
    @objc func armAlarm(_ call: CAPPluginCall) {
        let at = call.getDouble("at") ?? 0
        let u = call.getString("url") ?? ""
        let title = call.getString("title") ?? ""
        let art = call.getString("artwork") ?? ""
        DispatchQueue.main.async {
            self.alarmTimer?.invalidate(); self.alarmTimer = nil
            if at > 0, !u.isEmpty {
                let fire = Date(timeIntervalSince1970: at / 1000)
                let t = Timer(fire: fire, interval: 0, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    self.stopKeepAlive()
                    self.live = true
                    self.info = ["title": title, "artist": "Réveil · Effem Radio", "album": ""]
                    self.loadArtwork(art)
                    self.open(u)
                    self.wantPlaying = true
                    self.applyMute(false, notify: false)
                    self.activate()
                    self.player.play()
                    self.notifyListeners("state", data: ["ev": "alarm", "url": u])
                }
                RunLoop.main.add(t, forMode: .common)
                self.alarmTimer = t
                self.startKeepAlive()
            } else {
                self.stopKeepAlive()
            }
            call.resolve()
        }
    }

    // MARK: - Lecture

    private func activate() {
        let s = AVAudioSession.sharedInstance()
        try? s.setCategory(.playback, mode: .default, options: [])
        try? s.setActive(true)
    }

    private func open(_ u: String) {
        url = u
        itemObs.forEach { $0.invalidate() }; itemObs = []
        if let old = player.currentItem { NotificationCenter.default.removeObserver(self, name: nil, object: old) }
        guard let link = URL(string: u), !u.isEmpty else { player.replaceCurrentItem(with: nil); return }
        let item = AVPlayerItem(asset: AVURLAsset(url: link))
        item.preferredForwardBufferDuration = live ? 8 : 0
        itemObs.append(item.observe(\.status, options: [.new]) { [weak self] it, _ in
            DispatchQueue.main.async {
                guard let self = self, it == self.player.currentItem else { return }
                if it.status == .readyToPlay {
                    if !self.live, self.startAt > 5 { it.seek(to: CMTime(seconds: self.startAt, preferredTimescale: 600), completionHandler: nil); self.startAt = 0 }
                    self.emit("loadedmetadata"); self.emit("durationchange"); self.updateNowPlaying()
                } else if it.status == .failed {
                    self.failed()
                }
            }
        })
        itemObs.append(item.observe(\.duration, options: [.new]) { [weak self] it, _ in
            DispatchQueue.main.async { if it == self?.player.currentItem { self?.emit("durationchange"); self?.updateNowPlaying() } }
        })
        NotificationCenter.default.addObserver(self, selector: #selector(itemEnded(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
        NotificationCenter.default.addObserver(self, selector: #selector(itemFailed(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: item)
        player.replaceCurrentItem(with: item)
        player.isMuted = muted
    }

    private func stopAll() {
        wantPlaying = false
        cancelRetry()
        muteTimer?.invalidate(); muteTimer = nil
        player.pause()
        player.replaceCurrentItem(with: nil)
        muted = false; player.isMuted = false
        if alarmTimer != nil { keepAlive?.play() }   // un réveil est prévu : l'app doit rester éveillée
        updateNowPlaying()
    }

    private func applyMute(_ m: Bool, notify: Bool) {
        muted = m
        player.isMuted = m
        muteTimer?.invalidate(); muteTimer = nil
        if m {
            wantPlaying = false
            if keepMin > 0 {
                muteTimer = Timer.scheduledTimer(withTimeInterval: keepMin * 60, repeats: false) { [weak self] _ in
                    guard let self = self, self.muted else { return }
                    self.stopAll(); self.emit("pause")
                }
            }
        } else {
            wantPlaying = true
            if player.currentItem == nil, !url.isEmpty { open(url) }
            activate()
            player.play()
        }
        if notify { notifyListeners("state", data: ["ev": "mutechange", "muted": m]) }
        updateNowPlaying()
    }

    private func statusChanged() {
        switch player.timeControlStatus {
        case .playing:
            hadPlayed = true; retryN = 0
            stallTimer?.invalidate(); stallTimer = nil
            keepAlive?.pause()            // la radio garde déjà l'app éveillée
            emit("playing")
        case .waitingToPlayAtSpecifiedRate:
            emit("waiting")
            if live, wantPlaying {
                stallTimer?.invalidate()
                stallTimer = Timer.scheduledTimer(withTimeInterval: 12, repeats: false) { [weak self] _ in
                    guard let self = self, self.wantPlaying, self.player.timeControlStatus != .playing else { return }
                    self.scheduleRetry()
                }
            }
        default:
            break
        }
        updateNowPlaying()
    }

    @objc private func itemEnded(_ n: Notification) {
        DispatchQueue.main.async {
            if self.live, self.wantPlaying { self.scheduleRetry(); return }   // un direct qui « se termine » = coupure réseau
            self.wantPlaying = false
            self.emit("ended"); self.updateNowPlaying()
        }
    }

    @objc private func itemFailed(_ n: Notification) { DispatchQueue.main.async { self.failed() } }

    private func failed() {
        if live, wantPlaying, hadPlayed { scheduleRetry(); return }
        emit("error")
    }

    // Reconnexion d'un direct (réseau perdu, flux bloqué), même quand la page est endormie
    private func scheduleRetry() {
        guard live, wantPlaying, !url.isEmpty, retryTimer == nil, retryN < 40 else { return }
        let d = min(15.0, 1.5 * pow(1.5, Double(retryN)))
        retryN += 1
        emit("waiting")
        retryTimer = Timer.scheduledTimer(withTimeInterval: d, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.retryTimer = nil
            guard self.wantPlaying else { return }
            self.open(self.url); self.activate(); self.player.play()
        }
    }

    private func cancelRetry() {
        retryTimer?.invalidate(); retryTimer = nil
        stallTimer?.invalidate(); stallTimer = nil
        retryN = 0
    }

    private func emit(_ ev: String) {
        var d: [String: Any] = ["ev": ev, "muted": muted, "live": live]
        let t = player.currentTime().seconds
        d["t"] = t.isFinite ? t : 0
        if let dur = player.currentItem?.duration.seconds, dur.isFinite, dur > 0 { d["d"] = dur }
        notifyListeners("state", data: d)
    }

    // MARK: - Appels, Siri, alarmes

    @objc private func interruption(_ n: Notification) {
        guard let info = n.userInfo,
              let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
        DispatchQueue.main.async {
            if type == .began {
                // « L'app a été suspendue » n'est pas une vraie interruption : on l'ignore
                if #available(iOS 16.0, *), let r = info[AVAudioSessionInterruptionReasonKey] as? UInt,
                   AVAudioSession.InterruptionReason(rawValue: r) == .appWasSuspended { return }
                if (info[AVAudioSessionInterruptionWasSuspendedKey] as? Bool) == true { return }
                self.interrupted = true
                self.wasAudibleBeforeInterruption = self.wantPlaying && !self.muted && self.player.currentItem != nil
                self.cancelRetry()
                self.emit("pause")
                self.updateNowPlaying()
            } else {
                let opts = AVAudioSession.InterruptionOptions(rawValue: (info[AVAudioSessionInterruptionOptionKey] as? UInt) ?? 0)
                self.interrupted = false
                self.activate()
                if self.wasAudibleBeforeInterruption && opts.contains(.shouldResume) {
                    self.wantPlaying = true
                    if self.live { self.open(self.url) }   // on repart sur le direct, pas sur ce qui a été mis en mémoire avant l'appel
                    self.player.play()
                } else {
                    self.wantPlaying = false
                }
                self.wasAudibleBeforeInterruption = false
            }
        }
    }

    @objc private func mediaReset(_ n: Notification) {
        DispatchQueue.main.async {
            self.activate()
            if self.wantPlaying, !self.url.isEmpty { self.open(self.url); self.player.play() }
        }
    }

    // MARK: - Écran verrouillé et centre de contrôle

    private func setupRemote() {
        let c = MPRemoteCommandCenter.shared()
        c.playCommand.addTarget { [weak self] _ in self?.remotePlay(); return .success }
        c.pauseCommand.addTarget { [weak self] _ in self?.remotePause(); return .success }
        c.togglePlayPauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            if self.isAudible() { self.remotePause() } else { self.remotePlay() }
            return .success
        }
        c.stopCommand.addTarget { [weak self] _ in self?.stopAll(); self?.emit("pause"); return .success }
        c.nextTrackCommand.addTarget { [weak self] _ in self?.remoteStep(1); return .success }
        c.previousTrackCommand.addTarget { [weak self] _ in self?.remoteStep(-1); return .success }
        c.skipForwardCommand.preferredIntervals = [30]
        c.skipBackwardCommand.preferredIntervals = [30]
        c.skipForwardCommand.addTarget { [weak self] _ in self?.skip(30); return .success }
        c.skipBackwardCommand.addTarget { [weak self] _ in self?.skip(-30); return .success }
        c.changePlaybackPositionCommand.addTarget { [weak self] e in
            guard let self = self, let e = e as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.player.seek(to: CMTime(seconds: e.positionTime, preferredTimescale: 600)) { _ in self.emit("timeupdate"); self.updateNowPlaying() }
            return .success
        }
        updateCommands()
    }

    private func updateCommands() {
        let c = MPRemoteCommandCenter.shared()
        c.nextTrackCommand.isEnabled = live
        c.previousTrackCommand.isEnabled = live
        c.skipForwardCommand.isEnabled = !live
        c.skipBackwardCommand.isEnabled = !live
        c.changePlaybackPositionCommand.isEnabled = !live
    }

    private func isAudible() -> Bool { return wantPlaying && !muted && player.timeControlStatus != .paused }

    private func remotePlay() {
        interrupted = false; wasAudibleBeforeInterruption = false
        activate()
        if live {
            if muted, player.currentItem != nil, player.timeControlStatus != .paused {
                applyMute(false, notify: true)
            } else {
                muted = false; player.isMuted = false
                muteTimer?.invalidate(); muteTimer = nil
                wantPlaying = true
                open(url); activate(); player.play()
                notifyListeners("state", data: ["ev": "mutechange", "muted": false])
            }
        } else {
            wantPlaying = true; activate(); player.play()
        }
        updateNowPlaying()
    }

    private func remotePause() {
        if live {
            if keepMin > 0 { applyMute(true, notify: true) } else { stopAll(); emit("pause") }
        } else {
            wantPlaying = false; player.pause(); emit("pause")
        }
        updateNowPlaying()
    }

    private func remoteStep(_ d: Int) {
        guard live, !queue.isEmpty else { return }
        var i = queue.firstIndex { $0["url"] == url } ?? -1
        i = ((i + d) % queue.count + queue.count) % queue.count
        let s = queue[i]
        info = ["title": s["title"] ?? "", "artist": "En direct · Effem Radio", "album": ""]
        loadArtwork(s["artwork"] ?? "")
        cancelRetry(); hadPlayed = false
        muted = false; player.isMuted = false; muteTimer?.invalidate(); muteTimer = nil
        wantPlaying = true
        open(s["url"] ?? ""); activate(); player.play()
        notifyListeners("state", data: ["ev": "track", "url": s["url"] ?? ""])
        updateNowPlaying()
    }

    private func skip(_ s: Double) {
        let t = player.currentTime().seconds + s
        player.seek(to: CMTime(seconds: max(0, t), preferredTimescale: 600)) { _ in self.emit("timeupdate"); self.updateNowPlaying() }
    }

    private func updateNowPlaying() {
        updateCommands()
        guard player.currentItem != nil || wantPlaying else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var n: [String: Any] = [:]
        n[MPMediaItemPropertyTitle] = info["title"] as? String ?? "Effem"
        n[MPMediaItemPropertyArtist] = info["artist"] as? String ?? ""
        n[MPMediaItemPropertyAlbumTitle] = info["album"] as? String ?? ""
        if let a = artwork { n[MPMediaItemPropertyArtwork] = a }
        n[MPNowPlayingInfoPropertyIsLiveStream] = live
        n[MPNowPlayingInfoPropertyPlaybackRate] = isAudible() ? 1.0 : 0.0
        if !live {
            let t = player.currentTime().seconds
            if t.isFinite { n[MPNowPlayingInfoPropertyElapsedPlaybackTime] = t }
            if let d = player.currentItem?.duration.seconds, d.isFinite, d > 0 { n[MPMediaItemPropertyPlaybackDuration] = d }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = n
    }

    private func loadArtwork(_ src: String) {
        guard src != artworkKey else { return }
        artworkKey = src
        artwork = nil
        if src.hasPrefix("data:") {
            if let comma = src.firstIndex(of: ","), !src.hasPrefix("data:image/svg"),
               let data = Data(base64Encoded: String(src[src.index(after: comma)...])), let img = UIImage(data: data) {
                artwork = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
            }
            return
        }
        guard let link = URL(string: src), src.hasPrefix("https") else { return }
        URLSession.shared.dataTask(with: link) { [weak self] data, _, _ in
            guard let self = self, let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                guard self.artworkKey == src else { return }
                self.artwork = MPMediaItemArtwork(boundsSize: img.size) { _ in img }
                self.updateNowPlaying()
            }
        }.resume()
    }

    // Son silencieux qui garde l'app éveillée pour le réveil, seulement quand aucune radio ne joue
    private func startKeepAlive() {
        guard keepAlive == nil else { return }
        let rate = 8000, n = rate
        var d = Data()
        func u32(_ v: UInt32) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 4)) }
        func u16(_ v: UInt16) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 2)) }
        d.append("RIFF".data(using: .ascii)!); u32(UInt32(36 + n)); d.append("WAVEfmt ".data(using: .ascii)!)
        u32(16); u16(1); u16(1); u32(UInt32(rate)); u32(UInt32(rate)); u16(1); u16(8)
        d.append("data".data(using: .ascii)!); u32(UInt32(n)); d.append(Data(repeating: 128, count: n))
        activate()
        if let p = try? AVAudioPlayer(data: d) {
            p.numberOfLoops = -1; p.volume = 0
            p.play()
            keepAlive = p
        }
    }

    private func stopKeepAlive() { keepAlive?.stop(); keepAlive = nil }
}
