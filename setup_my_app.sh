#!/usr/bin/env sh
# This file is copied and adapted from https://github.com/mirego/elixir-boilerplate/blob/master/boilerplate-setup.sh

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

pascalCaseBefore="MyApp"
snakeCaseBefore="my_app"
kebabCaseBefore="my-app"

# The identifiers above will be replaced in the content of the files found below
content=$(find . -type f \( \
  -name "*.ex" -or \
  -name "*.exs" -or \
  -name "*.ees" -or \
  -name "*.heex" -or \
  -name "*.sh" -or \
  -name "*.json" -or \
  -name "*.js" -or \
  -name "*.yml" -or \
  -name "*.yaml" -or \
  -name "*.md" -or \
  -name ".env.*" -or \
  -name "Dockerfile" -or \
  -name "fly.toml" -or \
  -name "Makefile" \
\) \
  -and ! -path "./setup_my_app.sh" \
  -and ! -path "./assets/node_modules/*" \
  -and ! -path "./_build/*" \
  -and ! -path "./deps/*" \
)

# The identifiers above will be replaced in the path of the files and directories found here
paths=$(find . -depth 2 \( \
  -path "./lib/${snakeCaseBefore}" -or \
  -path "./lib/${snakeCaseBefore}_*" -or \
  -path "./test/${snakeCaseBefore}" -or \
  -path "./test/${snakeCaseBefore}_*" \
\))

files=$(find . \( \
  -path "./lib/${snakeCaseBefore}.*" -or \
  -path "./lib/${snakeCaseBefore}*/${snakeCaseBefore}*" \
\))

# -----------------------------------------------------------------------------
# Validation
# -----------------------------------------------------------------------------

if [[ -z $(echo "$1" | grep "^[A-Z]") ]] ; then
  echo 'You must specify your project name in PascalCase as first argument (eg. FooBar).'
  exit 0
fi

pascalCaseAfter=$1
snakeCaseAfter=$(echo $pascalCaseAfter | /usr/bin/sed 's/\(.\)\([A-Z]\{1,\}\)/\1_\2/g' | tr '[:upper:]' '[:lower:]')
kebabCaseAfter=$(echo $snakeCaseAfter | tr '_' '-')

# -----------------------------------------------------------------------------
# Helper functions
# -----------------------------------------------------------------------------

header() {
  echo "\033[0;33m▶ $1\033[0m"
}

success() {
  echo "\033[0;32m▶ $1\033[0m"
}

run() {
  echo ${@}
  eval "${@}"
}

# -----------------------------------------------------------------------------
# Execution
# -----------------------------------------------------------------------------

header "Configuration"
echo "${pascalCaseBefore} → ${pascalCaseAfter}"
echo "${snakeCaseBefore} → ${snakeCaseAfter}"
echo "${kebabCaseBefore} → ${kebabCaseAfter}"
echo ""

header "Replacing boilerplate identifiers in content"
for file in $content; do
  run /usr/bin/sed -i "s/$snakeCaseBefore/$snakeCaseAfter/g" $file
  run /usr/bin/sed -i "s/$kebabCaseBefore/$kebabCaseAfter/g" $file
  run /usr/bin/sed -i "s/$pascalCaseBefore/$pascalCaseAfter/g" $file
done
success "Done!\n"

header "Replacing boilerplate identifiers in file and directory paths"
for path in $paths; do
  run mkdir $(echo $path | /usr/bin/sed "s/$snakeCaseBefore/$snakeCaseAfter/g" | /usr/bin/sed "s/$kebabCaseBefore/$kebabCaseAfter/g" | /usr/bin/sed "s/$pascalCaseBefore/$pascalCaseAfter/g")
done
for file in $files; do \
  run mv $file $(echo $file | /usr/bin/sed "s/$snakeCaseBefore/$snakeCaseAfter/g" | /usr/bin/sed "s/$kebabCaseBefore/$kebabCaseAfter/g" | /usr/bin/sed "s/$pascalCaseBefore/$pascalCaseAfter/g")
done
for path in $paths; do
  run mv $path/* $(echo $path | /usr/bin/sed "s/$snakeCaseBefore/$snakeCaseAfter/g" | /usr/bin/sed "s/$kebabCaseBefore/$kebabCaseAfter/g" | /usr/bin/sed "s/$pascalCaseBefore/$pascalCaseAfter/g")
  run rm -rf $path
done
find . -iname "${snakeCaseBefore}_*" -exec rename -v "s/${snakeCaseBefore}$/${snakeCaseAfter}/i" {} \;
find . -iname "${snakeCaseBefore}" -exec rename -v "s/${snakeCaseBefore}$/${snakeCaseAfter}/i" {} \;
success "Done!\n"

header "Selfdestruct setup script"
run rm -rf setup_my_app.sh
success "Done!\n"
