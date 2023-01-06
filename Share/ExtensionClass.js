var ExtensionClass = function() {};

ExtensionClass.prototype = {
    getImage: function() {
        var metas = document.getElementsByTagName('meta');
        for (i=0; i<metas.length; i++) {
            if (metas[i].getAttribute("property") == "og:image" || metas[i].getAttribute("property") == "twitter:image") {
               return metas[i].getAttribute("content");
            }
        }
        return "";
    },
    run: function(arguments) {
        arguments.completionFunction({
            "currentUrl": document.baseURI,
            "currentTitle": document.title,
            "images": this.getImage(),
        });
    }
};

var ExtensionPreprocessingJS = new ExtensionClass;

