
option=$1
abort=false
currentVersion=''
newVersion=''
currentDateTime=$(date +"%Y-%m-%d %T")
currentDate=$(date +"%Y-%m-%d")

#region functions

function showHelp {
    echo 'Parameter invalid / missing.'
    echo ''
    echo 'usage:'
    echo ''
    echo '  bump_version [patch|minor|major]'
    echo ''
} 

function checkParameters {
   
    if [ -z $option ]; 
    then 
        showHelp
        abort=true
    else
        case $option in
        patch)
            
            ;;
        minor)
            
            ;;
        major)
            
            ;;
        *)
            showHelp
            abort=true
            return
            ;;
        esac 
        echo "bump ${option} version"
    fi
}


function read_current_version {
    currentVersion=$(echo "$var1" | (grep version package.json | sed 's/.*"version": "\(.*\)".*/\1/'))
    echo "currentVersion=${currentVersion}"
}

function get_new_version {
    local currentMajor=$(echo "$var1" | (echo "${currentVersion}" | awk -F'.' '{print $1}'))
    local currentMinor=$(echo "$var1" | (echo "${currentVersion}" | awk -F'.' '{print $2}'))
    local currentPatch=$(echo "$var1" | (echo "${currentVersion}" | awk -F'.' '{print $3}'))

    echo "${currentMajor} ${currentMinor} ${currentPatch}"
     case $option in
        patch)
            let "newPatch = $currentPatch + 1"
            newVersion="${currentMajor}.${currentMinor}.${newPatch}"
            echo "newVersion=${newVersion}"
            ;;
        minor)
            let "newMinor = $currentMinor + 1"
            newVersion="${currentMajor}.${newMinor}.0"
            echo "newVersion=${newVersion}"
            ;;
        major)
            let "newMajor = $currentMajor + 1"
            newVersion="${newMajor}.0.0"
            echo "newVersion=${newVersion}"
            ;;
        esac 
}

function search_replace_in_file {
    local file=$1
    local search=$2
    local replace=$3

    sed -i "" "s/${search}/${replace}/g" $file
}

function write_new_version {
    
    echo ""
    echo "Update files to ${newVersion} (${currentDateTime}):"

    echo " package.json"
    local line="\"version\": \".*\""
    local rep="\"version\": \"${newVersion}\""
    sed -i "" "s/${line}/${rep}/g" package.json

   
    echo " package-lock.json"
    sed -e "/${line}/{s//${rep}/;:a" -e '$!N;$!ba' -e '}' package-lock.json > tmp && mv tmp package-lock.json


   
    echo " web-app-manifest.json"
    sed -i "" "s/${line}/${rep}/g" web-app-manifest.json

    echo " manifest.json"
    sed -i "" "s/${line}/${rep}/g" manifest.json


    echo " pacman-canvas.webapp"
    sed -i "" "s/${line}/${rep}/g" pacman-canvas.webapp

    echo " cache.manifest"
    local line="# Pacman .*"
    local rep="# Pacman ${newVersion} ${currentDateTime}"
    sed -i "" "s/${line}/${rep}/g" cache.manifest

    echo " index.htm"
    local line="<span class=\"app-version\">.*<\/span>"
    local rep="<span class=\"app-version\">${newVersion} (${currentDate})<\/span>"
    sed -i "" "s/${line}/${rep}/g" index.htm

    echo ""
    echo "All files up to date. New Version ${newVersion} (${currentDateTime})."
    echo "Don't forget to update README.md and to set the git tag."
}

function run {
  

    echo "run ${option}"

    checkParameters

    if [[ ${abort} == true ]];
    then
        return
    fi

    echo "bump version $option"

    read_current_version
    get_new_version

   

    write_new_version
}



run

