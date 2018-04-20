# request
request 用ctx.py: RequestCtx中被引用:

    request = app.request_class(environ)

而app.py 会中:

    from .wrapper import Request,Response
    def Flask():
        request_class = Request

位于flask/wrapper.py

    from werkzeug.wrappers import Request as RequestBase, Response as ResponseBase
    class Request(RequestBase, JSONMixin):

werkzeug.wrapper 中

    class Request(BaseRequest, AcceptMixin, ETagRequestMixin,
              UserAgentMixin, AuthorizationMixin,
              CommonRequestDescriptorsMixin):

    """Full featured request object implementing the following mixins:
    - :class:`AcceptMixin` for accept header parsing
    - :class:`ETagRequestMixin` for etag and cache control handling
    - :class:`UserAgentMixin` for user agent introspection
    - :class:`AuthorizationMixin` for http auth handling
    - :class:`CommonRequestDescriptorsMixin` for common headers
    """

BaseRequest 中定义了常用参数: args/form/data raw/files:

    # lazy property
    @cached_property
    def form(self):
        self._load_form_data()
        return self.form

from werkzeug.formparser import FormDataParser:
1.  url_decode_stream(stream)
    1. wsgi.py: pair_iter = make_chunk_iter(stream) : a=1 构成一个pair
    1. urls.py:_url_decode_impl(pair_iter)
        2. _compat.py: s=make_literal_wrapper(stream_pair)




