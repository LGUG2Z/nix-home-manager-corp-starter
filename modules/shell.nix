_: let
  # FIXME: Add whatever git shortcuts you want
  git_shortcuts = {
    gapa = "git add --patch";
    grpa = "git reset --patch";
    gst = "git status";
    gdh = "git diff HEAD";
    gp = "git push";
    gph = "git push -u origin HEAD";
    gco = "git checkout";
    gcob = "git checkout -b";
    gcm = "git checkout master";
    gcd = "git checkout develop";
  };

  navigation_shortcuts = {
    ".." = "cd ..";
    "..." = "cd ../../";
    "...." = "cd ../../../";
    "....." = "cd ../../../../";
  };
in {
  inherit git_shortcuts navigation_shortcuts;
}
