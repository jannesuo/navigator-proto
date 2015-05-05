## City Navigator native wrapper ##

See the [wiki](https://github.com/dippi/navigator-proto/wiki) for documentation.  
And the Navigator [repo](https://github.com/HSLdevcom/navigator-proto) for other details.


# Setup

1. Expected tools to be installed in system
 - Git [http://git-scm.com/]
 - Apache Cordova [https://cordova.apache.org/]
 - Node.js / NPM (node package manager) [https://nodejs.org/download/]
 - Grunt [http://gruntjs.com/]

2. Create project and download plugins & content:
```
cordova create "navigator-wrapper" "fi.hsl.navigator" "HSL Navigator"
cd navigator-wrapper
cordova platform add android
cordova plugin add https://github.com/pekman/navigator-plugin.git
cd www
del /f /s /q *.*  (windows) || rm -rf * (linux)
git clone https://github.com/jannesuo/navigator-proto.git .
npm install
grunt
```

# Related GitHub repositories
* Cordova plugin to add all dependencies [https://github.com/pekman/navigator-plugin]
* Server component for push notifications [https://github.com/Mankro/navigator-push-server]

# Demo video of some of the features
* Youtube video: https://www.youtube.com/watch?v=zHRgK4Vl70Q


# Terms of use
All the source code in this repository that is not licensed by the fork source, is licensed with MIT open source license. The software code is provided "as is" and is free for use in any open source applications.
