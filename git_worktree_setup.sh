#!/bin/sh

# https://nicknisi.com/posts/git-worktrees/

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <remote-repo-url> <local-dir-name>"
  echo "Example: $0 git@github.com:user/my-project.git my-project"
  exit 1
fi

repourl="$1"
dirname="$2"

printf "Clone a bare repo, '%s', into '%s'? (y/n) " "$repourl" "$dirname"
read -r answer

case "$answer" in
  [Nn]*)
    exit 0
    ;;
  *)
    ;;
esac

set -x

mkdir -p "$dirname" || exit 1
git clone --bare "$repourl" "$dirname/.bare" || exit 1
echo "gitdir: ./.bare" > "$dirname/.git" || exit 1
cd "$dirname" || exit 1
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' || exit 1
# git fetch || exit 1
# git for-each-ref --format='%(refname:short)' refs/heads | xargs -n1 -I{} git branch --set-upstream-to=origin/{} || exit 1

touch setup_branch.sh || exit 1

cat > setup_branch.sh << 'EOF'
#!/bin/sh

if [ -z "$1" ]; then
  echo "Error: directory/worktree branch not provided."
  exit 1
fi

if [ "$1" = "main" ] || [ "$1" = "master" ]; then
  echo "Error: directory/worktree cannot be '$dir'."
  exit 1
fi

dir="$1"

shift

while [ "$1" != "" ]; do
    case "$1" in
        --new-branch)
            newbranch=1
            ;;
        --existing-branch)
            newbranch=0
            ;;
        *)
            echo "Error: Unknown option $1"
            exit 1
            ;;
    esac
    shift
done

set -x

git worktree add "$1" -b "$1"

# TODO - Automate the steps to create a new branch.

EOF

