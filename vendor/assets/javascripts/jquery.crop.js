/* jQuery-crop v1.0.2, based on jWindowCrop v1.0.0
 * Copyright (c) 2012 Tyler Brown
 * Modified by Adrien Gibrat
 * Licensed under the MIT license.
 */
( function ( $, undefined ) {
    var namespace = 'crop' // IE sucks
        , plugin  = function ( image, options ) {
            var self  = this
                , img = new Image();
            this.$image  = $( image ).wrap( '<div class="' + namespace + 'Frame"/>' ) // wrap image in frame;
            this.options = $.extend({}, this.options, {
                width    : this.$image.attr('width')
                , height : this.$image.attr('height')
            }, options );
            this.$frame  = this.$image.parent();
            this.$image
                .hide() // hide image until loaded
                .addClass( namespace + 'Image' )
                .data( namespace, this )
                .on( 'mousedown.' + namespace, function ( event ) {
                    event.preventDefault(); //some browsers do image dragging themselves
                    $( document )
                        .on( 'mousemove.' + namespace, {
                            mouse : {
                                x   : event.pageX
                                , y : event.pageY
                            }
                            , image : {
                                x   : parseInt( self.$image.css( 'left' ), 10 )
                                , y : parseInt( self.$image.css( 'top' ), 10 )
                            }
                        }, $.proxy( self.drag, self ) )
                        .on( 'mouseup.' + namespace, function () {
                            $( document ).off( '.' + namespace )
                        } );
                } )
                .on( 'load.' + namespace, function () {
                    if (img.naturalWidth === undefined) {
                        img.src = self.$image.attr('src'); // should not need to wait image load event as src is loaded
                        self.$image.prop('naturalWidth', img.width);
                        self.$image.prop('naturalHeight', img.height);
                    }
                    var width    = self.$image.prop('naturalWidth')
                        , height = self.$image.prop('naturalHeight');
                    self.minPercent = Math.max( width ? self.options.width / width : 1, height ? self.options.height / height : 1 );
                    self.focal      = { x : Math.round( width / 2 ), y : Math.round( height / 2 ) };
                    self.zoom( self.minPercent );
                    self.$image.fadeIn( 'fast' ); //display image now that it is loaded
                } )
                .trigger('load.' + namespace); // init even if image is already loaded
            this.$frame
                .css( { width : this.options.width, height : this.options.height } )
                .append( this.options.loading )
                .hover(function(){self.$frame.toggleClass('hover');});
            if ( this.options.controls !== false )
                this.$frame
                    .append( $( '<div/>', { 'class' : namespace + 'Controls' } )
                        .append( $( '<span/>' ).append( this.options.controls ) )
                        .append( $( '<a/>', { 'class' : namespace + 'ZoomIn' } ).on( 'click.' + namespace, $.proxy( this.zoomIn, this ) ) )
                        .append( $( '<a/>', { 'class' : namespace + 'ZoomOut' } ).on( 'click.' + namespace, $.proxy( this.zoomOut, this ) ) )
                    );
        }
        ;
    $[ namespace ] = $.extend( plugin
        , {
            prototype : {
                percent : null
                , options : {
                    width      : 320
                    , height   : 180
                    , zoom     : 10
                    , stretch  : 1
                    , loading  : 'Loading...'
                    , controls : 'Click to drag'
                }
                , zoom    : function ( percent ) {
                    this.percent = Math.max( this.minPercent, Math.min( this.options.stretch, percent ) );
                    this.$image.width( Math.ceil( this.$image.prop('naturalWidth') * this.percent ) );
                    this.$image.height( Math.ceil( this.$image.prop('naturalHeight') * this.percent ) );
                    this.$image.css( {
                        left  : plugin.fill( - Math.round( this.focal.x * this.percent - this.options.width / 2 ), this.$image.width(), this.options.width )
                        , top : plugin.fill( - Math.round( this.focal.y * this.percent - this.options.height / 2 ), this.$image.height(), this.options.height )
                    } );
                    this.update();
                }
                , drag  : function ( event ) {
                    this.$image.css( {
                        left  : plugin.fill( event.data.image.x + event.pageX - event.data.mouse.x, this.$image.width(), this.options.width )
                        , top : plugin.fill( event.data.image.y + event.pageY - event.data.mouse.y, this.$image.height(), this.options.height )
                    } );
                    this.update();
                }
                , zoomIn  : function () {
                    return !! this.zoom( this.percent + 1 / ( this.options.zoom - 1 || 1 ) );
                }
                , zoomOut : function () {
                    return !! this.zoom( this.percent - 1 / ( this.options.zoom - 1 || 1 ) );
                }
                , update  : function () {
                    this.focal = {
                        x   : Math.round( ( this.options.width / 2 - parseInt( this.$image.css( 'left'), 10 ) ) / this.percent )
                        , y : Math.round( ( this.options.height / 2 - parseInt( this.$image.css ('top' ), 10 ) ) / this.percent )
                    };
                    this.$image.trigger( $.Event( 'crop', {
                        cropX     : - Math.floor( parseInt( this.$image.css( 'left' ), 10 ) / this.percent )
                        , cropY   : - Math.floor( parseInt( this.$image.css( 'top' ), 10 ) / this.percent )
                        , cropW   : Math.round( this.options.width / this.percent )
                        , cropH   : Math.round( this.options.height / this.percent )
                        , stretch : this.percent > 1
                    } ) );
                }
            }
            // ensure that no gaps are between target's edges and container's edges
            , fill    : function ( value, target, container ) {
                if ( value + target < container )
                    value = container - target;
                return value > 0 ? 0 : value;
            }
        } );

    $.fn[ namespace ] = function ( options ) {
        return this.each( function () {
            new plugin( this, options );
        } );
    };

} )( jQuery );