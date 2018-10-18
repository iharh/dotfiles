# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

dusg ()
{
  sudo du -hxcd "$1" | sort --human-numeric-sort
# sudo du -hxcd 5 | grep [0-9]G | sort -rnk1,1
}

# wrk

scp-to-rr1 ()
{
  scp "$@" ihar.hancharenka@roadrunner1.clarabridge.net:/home/ihar.hancharenka/
}

scp-from-pd () {
  scp ihar.hancharenka@platform-dev:"$@"
}
scp-to-pd () {
  scp "$@" ihar.hancharenka@platform-dev:/home/ihar.hancharenka/
}

scp-to-epam-msa () {
  rsync -aPvzl -e ssh "$1" "ihar_hancharenka@epam.com@ECSD001004F7.epam.com:/home/ihar_hancharenka@epam.com/transfer/"
}
scp-from-epam-msa () {
  #rsync -aPvzl -e ssh "jenkins@ECSD001004F7.epam.com:/data/wrk/deep-thought/cb-cps-app/build/reports/tests/" ~/transfer/
  rm -rf ~/transfer/*
  rsync -aPvzl -e ssh "jenkins@ECSD001004F7.epam.com:/data/wrk/deep-thought/target/reports/" ~/transfer/
}
