enum AudioPlayerError: Error {
    case invalidAudioId
    case invalidFriendlyName
    case invalidPath
    case invalidSeekTime
    case invalidVolume
    case invalidRate
    case invalidSource
    case missingAudioSource
}
