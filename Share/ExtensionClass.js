var ExtensionClass = function() {};

ExtensionClass.prototype = {
    run: function(arguments) {
        arguments.completionFunction({
            "currentUrl": document.URL,
            "currentTitle": document.title,
            "images": document.querySelector("meta[property='og:image']").getAttribute('content'),
        });
    }
};

var ExtensionPreprocessingJS = new ExtensionClass;
