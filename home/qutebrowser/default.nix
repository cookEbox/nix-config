{ pkgs, ... }:

let
  qutebrowserWithBrowserPlist = pkgs.qutebrowser.overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      plist="$out/Applications/qutebrowser.app/Contents/Info.plist"

      if [ -f "$plist" ]; then
        /usr/libexec/PlistBuddy -c "Delete :CFBundleURLTypes" "$plist" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$plist" 2>/dev/null || true

        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLName string Web URL" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleTypeRole string Viewer" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:LSHandlerRank string Default" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string http" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:1 string https" "$plist"

        /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes array" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0 dict" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string HTML Document" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Viewer" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSHandlerRank string Alternate" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes array" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:0 string public.html" "$plist"
        /usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:1 string public.xhtml" "$plist"
      fi
    '';
  });
in

{
  programs.qutebrowser = {
    enable = true;
    package = qutebrowserWithBrowserPlist;

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
