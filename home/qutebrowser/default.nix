{ ... }:

{
  programs.qutebrowser = {
    enable = true;

    settings = {
      # Preserve open tabs/windows between restarts.
      auto_save.session = true;

      # Restored tabs only load when focused.
      session.lazy_restore = true;

      # Workaround for QtWebEngine 6.9.1 permission prompt issue.
      qt.args = [
        "disable-features=PermissionElement"
      ];

      # Site permissions for microphone/camera.
      content.media.audio_capture = "ask";
      content.media.video_capture = "ask";
      content.media.audio_video_capture = "ask";
    };
  };
}
