class MapTypeConfig {
  final String name;
  final String urlTemplate;
  final String attribution;
  final int maxZoom;
  final int minZoom;

  const MapTypeConfig({
    required this.name,
    required this.urlTemplate,
    required this.attribution,
    this.maxZoom = 18,
    this.minZoom = 1,
  });

  static const List<MapTypeConfig> mapTypes = [
    MapTypeConfig(
      name: 'Calles',
      urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
      attribution: '© Esri — DeLorme, NAVTEQ',
      maxZoom: 18,
      minZoom: 1,
    ),
    MapTypeConfig(
      name: 'Satélite',
      urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      attribution: '© Esri — i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
      maxZoom: 18,
      minZoom: 1,
    ),
    MapTypeConfig(
      name: 'Terreno',
      urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
      attribution: '© Esri — DeLorme, NAVTEQ, TomTom, Intermap, iPC, USGS, FAO, NPS, NRCAN, GeoBase, Kadaster NL, Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), and the GIS User Community',
      maxZoom: 18,
      minZoom: 1,
    ),
    MapTypeConfig(
      name: 'Híbrido',
      urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      attribution: '© Esri — i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
      maxZoom: 18,
      minZoom: 1,
    ),
  ];
}

