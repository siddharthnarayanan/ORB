from django.conf.urls import patterns, include, url
from django.contrib import admin

urlpatterns = patterns('',
    # Examples:
    # url(r'^$','orb/orb.html', name='orbhome'),

    # url(r'^$', 'home.views.index', name='home'),
    url(r'^home/', include('home.urls'), name='home')
    # url(r'^blog/', include('blog.urls')),

    # url(r'^admin/', include(admin.site.urls)),

)
