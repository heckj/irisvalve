from django.contrib import admin
from irisvalve.models import Tile, MapLocation

class TileInline(admin.TabularInline):
    model = Tile

class MapLocationAdmin(admin.ModelAdmin):
    inlines = (TileInline,)
    list_display = ('x', 'y')

admin.site.register(MapLocation, MapLocationAdmin)
