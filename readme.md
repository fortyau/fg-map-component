FG Component: fgMapComponent
============================

Add a description here


Setup
=====

Init a git repo, add all of the files, and commit:
`git init && git add . && git commit -m 'Initial FG Component creation'`

Add your project remote, push it:
`git remote add origin {{project_remote}} && git push origin master`


The entirety of the project should be setup at this point.
All that you need to do with your nice new component is add any custom code



First Time Running
==================

None of the required node packages are in your project file, and they should not be tracked in source control
Anytime someone pulls the project to work on it they need to do these things.

Install the dependencies in the local node_modules folder.
By default, npm install will install all modules listed as dependencies. With the --production flag, npm will not install modules listed in devDependencies.
`npm install`

Install packages with bower install. Bower installs packages to bower_components/.
`bower install`



Local Testing
=============


You can start the app using `grunt serve`

Grunt handles 





Deployment
==========

All of the component code is hosted at {{component_git_repo}}

The standard HCA four branch development is followed.
development  // not dev or wip
qa
staging
master


Grunt will handle the build and deployment to the different Environments

## Deploying your updates
first:      delete the dist folder
then run:   `grunt build:ENV`
then:       commit the changes
finally:    `grunt deploy:ENV`

Ideally this should be `grunt deploy:ENV`



Injection
=========

Say that you need this component on your mindtouch page, you want to use the fg-component-injector (TM)(C)
The file is created when yo generates the project and is updated on build with your newest code.

### to use the fg-component-injector:

Run: `grunt deploy:ENV`
Then put this on your page:
<script id="script#fgMapComponentAppInjector" src="{{url}}/componentize.js"></script>