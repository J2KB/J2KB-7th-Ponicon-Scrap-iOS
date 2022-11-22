var ExtensionClass = function() {};

ExtensionClass.prototype = {
    imageURLs: function() {
        var imgs = document.getElementsByTagName("img");
        var imgSrcs = [];

        for (var i = 0; i < imgs.length; i++) {
            imgSrcs.push(imgs[i].src);
        }
        return imgSrcs;
    },
    run: function(arguments) {
        arguments.completionFunction({
            "currentUrl": document.URL,
            "currentTitle": document.title,
            "images": this.imageURLs(),
        });
    }
};

var ExtensionPreprocessingJS = new ExtensionClass;
