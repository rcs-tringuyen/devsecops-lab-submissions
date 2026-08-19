endocryne@LE11-DDY5LPB4:~/devsecops/homework$ git config --global gpg.format
ssh
endocryne@LE11-DDY5LPB4:~/devsecops/homework$ git config --global user.signingkey
/home/endocryne/.ssh/id_ed25519.pub
endocryne@LE11-DDY5LPB4:~/devsecops/homework$ git config --global commit.gpgsign
true
endocryne@LE11-DDY5LPB4:~/devsecops/homework$ git log --show-signature -1
commit 0c3be7ee3eec180edab4e76db39587efc5e926a0 (HEAD -> feature/lab3.1, origin/feature/lab3.1)
Good "git" signature for tlnguyen@ualberta.ca with ED25519 key SHA256:vkO7RpTuGG6NeXqeGoCgOnXwyeoickZi9b3Dkt4/7Ow
Author: Anh Mat Em Roi <tlnguyen@ualberta.ca>
Date:   Wed Aug 19 16:52:05 2026 +0700

    test: first signed commit
