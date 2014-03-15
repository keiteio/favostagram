;(function($, window, document) {

	var documentElement = document.documentElement;

	/**
	 * jQuery prototype
	 */
	$.fn.photoLoader = function() {
		$.PhotoLoader.init(this);
		return this;
	};

	/**
	 * Photo loader
	 */
	var self = $.PhotoLoader = {
		url: '/images',
		page: 1,
		count: 5,
		enable: true,
		remainHeight: 500,

		init: function(target) {
			var rootNode, i = 0, words = 'Now Loading...', word, html = '';

			// Root node
			self.rootNode = $('<ul></ul>');
			rootNode = self.rootNode[0];

			// Now Loading "spanspan"
			while (word = words.charAt(i++)) {
				html += word === ' ' ? word : '<span>'+ word +'</span>';
			}
			self.loadingNode = $('<p class="nowLoading">' + html +'</p>');

			// Append
			$(target).append(self.rootNode, self.loadingNode);

			// List nodes
			self.listNodes = rootNode.getElementsByTagName('li');

			// Image nodes
			self.imageNodes = rootNode.getElementsByTagName('img');

			// Bind click event
			self.rootNode.delegate('a', 'click.PhotoLoader', function() {
				window.open(this.href, null);
				return false;
			});

			// Bind scroll event
			$(window).bind('scroll.PhotoLoader', function() {
				self.scrollHandler();
			}).trigger('scroll.PhotoLoader');
		},

		scrollHandler: function() {
			var remain = Math.max(documentElement.scrollHeight,
 			                      document.body.scrollHeight)
			           - documentElement.clientHeight
			           - (window.pageYOffset || documentElement.scrollTop);

			if (self.enable && remain <= self.remainHeight) {
				self.request();
			}
			self.evacuator();
		},

		request: function() {
			if (!self.enable) {
				return false;
			}
			self.enable = false;
			self.loadingNode.show();

			$.ajax({
				dataType: 'json',
				url: self.url,
				data: {
					max_id: self.max_id,
					count: self.count
				},
				success: function(json) {
					self.enable = true;
					self.success(json);
				},
				error: function() {
					self.error();
				}
			});
		},

		success: function(json) {
			var df = document.createDocumentFragment(),
			    i = 0, length = json.urls.length, data, listNode;
			while (i < length) {
				url = json.urls[i++];
				listNode = document.createElement('li');
				listNode.innerHTML = [
					'<a href="'+ url +'">',
						'<img src="'+ url +'" data-src="'+ url +'" alt="">',
					'</a>'
				].join('');
				df.appendChild(listNode);
			}
			self.loadingNode.hide();
			self.rootNode[0].appendChild(df);
			if (self.max_id == json.max_id) {
				self.enable = true;
			} else {
				self.max_id = json.max_id;
			}
		},

		error: function() {
		},

		dummySrc: 'data:image/gif;,',

		evacuator: function() {
			self.isScroll = true;
			if (self._scrollTimerId) {
				clearTimeout(self._scrollTimerId);
				self._scrollTimerId = null;
			}
			self._scrollTimerId = setTimeout(function() {
				self.isScroll = false;
				self._evacuator();
			}, 300);
		},

		_evacuator: function() {
			var scrTop = window.pageYOffset || documentElement.scrollTop,
			    scrBtm = scrTop + documentElement.clientHeight,
			    length = self.listNodes.length,
			    i = 0, li, img, src, isEvacuate;

			for (; i < length; ++i) {
				if (!self.enable) {
					return;
				}
				li  = self.listNodes[i];
				img = self.imageNodes[i];
				src = img.getAttribute('src');
				isEvacuate = Math.abs(li.getBoundingClientRect().top) > 50000;
				if (src !== self.dummySrc && isEvacuate) {
					img.setAttribute('style', 'display: none');
					img.setAttribute('src', self.dummySrc);
				}
				if (src === self.dummySrc && !isEvacuate) {
					img.setAttribute('src', img.getAttribute('data-src'));
					img.setAttribute('style', 'display: inline');
				}
			}
		}
	};

})(jQuery, this, document);
