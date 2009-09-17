# -*- coding: utf-8 -*-
from django.db.models import permalink
from google.appengine.ext import db
#from django.db.models import signals
#from ragendja.dbutils import cleanup_relations

class Tile(db.Model):
    """Basic user profile with personal details."""
    name = db.StringProperty(required=True)
    image = db.LinkProperty(required=True)
    
    def __unicode__(self):
        return '%s %s' % (self.name, self.image)

    def tag(self):
        return '<img src="%s" alt="%s">' % (self.image, self.name)

    @permalink
    def get_absolute_url(self):
        return ('irisvalve.views.show_tile', (), {'key': self.key()})

class MapLocation(db.Model):
    x = db.IntegerProperty(required=True)
    y = db.IntegerProperty(required=True)
    tile = db.ReferenceProperty(Tile, required=True)
    #name = db.StringProperty(required=True)
    #file = db.BlobProperty(required=True)

    @permalink
    def get_absolute_url(self):
        return ('irisvalve.views.display_map', (), {'key': self.key()})
    def __unicode__(self):
        return u'MapLocation [%s,%s]: %s' % (self.x, self.y, self.tile.name)

# class Contract(db.Model):
#     employer = db.ReferenceProperty(Person, required=True, collection_name='employee_contract_set')
#     employee = db.ReferenceProperty(Person, required=True, collection_name='employer_contract_set')
#     start_date = db.DateTimeProperty()
#     end_date = db.DateTimeProperty()
