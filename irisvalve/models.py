# -*- coding: utf-8 -*-
from django.db.models import permalink
from google.appengine.ext import db
#from django.db.models import signals
#from ragendja.dbutils import cleanup_relations

class Tile(db.Model):
    """Basic user profile with personal details."""
    name = db.StringProperty(required=True)
    image = db.LinkProperty(required=True)
    blocked = db.BooleanProperty(required=True)
    opacity = db.IntegerProperty(required=True)
    
    def __unicode__(self):
        return '%s %s' % (self.name, self.image)

    def tag(self):
        return '<img src="%s" alt="%s">' % (self.image, self.name)

    @permalink
    def get_absolute_url(self):
        return ('irisvalve.views.show_tile', (), {'key': self.key()})

class Map(db.Model):
    """
    >>> open = Tile(image='http://www.foo.com/open.png',name='open',blocked=False,opacity=0).put()
    >>> Map(x=1,y=1,name="testmap",tile=open).put()
    datastore_types.Key.from_path(u'irisvalve_map', 8L, _app_id_namespace=u'irisvalve')
    """
    x = db.IntegerProperty(required=True)
    y = db.IntegerProperty(required=True)
    tile = db.ReferenceProperty(Tile, required=True)
    name = db.StringProperty(required=True)

    @permalink
    def get_absolute_url(self):
        return ('irisvalve.views.display_map', (), {'key': self.key()})
    def __unicode__(self):
        return u'MapLocation [%s,%s]: %s' % (self.x, self.y, self.tile.name)

class GameObject(db.Model):
    """
    >>> GameObject.all().count()
    0
    >>> x = GameObject().put()
    >>> GameObject.all().count()
    1
    >>> x=GameObject.all()[0]
    >>> x.weight
    0.0
    >>> x.image
    >>> x.active
    False
    >>> x.delete()
    >>> GameObject.all().count()
    0
    """
    image = db.LinkProperty(required=False)
    active = db.BooleanProperty(required=True,default=False)
    weight = db.FloatProperty(required=True,default=0.0)