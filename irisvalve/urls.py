# -*- coding: utf-8 -*-
from django.conf.urls.defaults import *

urlpatterns = patterns('irisvalve.views',
    (r'^show_tile$', 'show_tile'),
    (r'^display_map$', 'display_map'),
    (r'^$', 'index'),
    # (r'^create/$', 'add_person'),
    # (r'^show/(?P<key>.+)$', 'show_person'),
    # (r'^edit/(?P<key>.+)$', 'edit_person'),
    # (r'^delete/(?P<key>.+)$', 'delete_person'),
    # (r'^download/(?P<key>.+)/(?P<name>.+)$', 'download_file'),
)
