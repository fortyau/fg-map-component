// In the grunt script on build:

// Componentizer will take somme magic fairy dust, sprinkle it around and make a file called component.js
// Then there is a replace function.
// THe replace function will take this file and start swapping bits in and out of it.
// It will take the component.js file and add the entirety of this file to the bottom of it.
// It will also go through and take any variables such as {{appname}} or {{url}}
// after that it will take the contents of main.html and swap it for {{main.html}}

// It will then also swap out the loadernator init script, and replace it with one that has a callback
// >>> {{scriptAppName}}.loadonater.process_project_dependencies( {{scriptAppName}}.dependencies );

// This callback is ran after all of the loadernator dependencies are loaded into the dom
// It will inject the html template,
// It will inject the config.js and main.js onto the page.

// then it should be ready for you to call


{{scriptAppName}}.injector: {
    template: '<div ng-app="{{scriptAppName}}" id="ng-app">{{main.html}}</div>',

    run: function(){
        // Find the script tag on this page
        var injection_script_tag = $("script#{{appname}}Injector");
        // Add the template before this point
        $({{scriptAppName}}.injector.template).insertBefore(injection_script_tag);

        // Add the config and main js files
        $('body').append('<script src="{{url}}/scripts/config.js"><script>');
        $('body').append('<script src="{{url}}/scripts/main.js"><script>');

    }
}