require 'json'

def lines
  s = ''
  [
    %w{AN010 #000 1}, # railway
    %w{AN500 #e7b2a8 2}, # raliway network link
    %w{AP030 #ccc 1}, # road
    %w{AP050 #ccc 1}, # trail
    %w{AP500 #ccc 1}, # road network link
    %w{AQ040 #f00 2}, # bridge
    %w{AQ070 #5494a8 1}, # ferry route
    %w{AQ130 #f00 2}, # tunnel
    %w{BA010 #5494a8 1}, # coastline
    %w{BH140 #54a498 1}, # river
    %w{BH210 #5494a8 1}, # inland shoreline
    %w{BH502 #5494a8 1}, # watercourse
    %w{BI020 #aaf 2}, # dam
    %w{BI030 #aaf 2}, # lock
    %w{FA000 #f00 1}, # administrative boundary
    %w{XX500 #00f 1} # sea limit
  ].each {|r|
  s += <<-EOS
  map.addLayer({
    'id': '#{r[0]}',
    'type': 'line', 'source': 'globalmaps-vt', 'source-layer': 'ls#{r[0]}',
    'layout': {'line-join': 'round', 'line-cap': 'round'},
    'paint': {
      'line-color': #{r[1] ? '\'' + r[1] + '\'' : 'randomColor()'},
      'line-width': #{r[2] ? r[2] : 1}
    }
  });
  EOS
  }
  s
end

def points
  s = ''
  [
    %w{AL020 nam}, # builtup area
    %w{AL105 nam}, # settlement
    %w{AN060}, # railroad yard
    %w{AP020}, # interchange
    %w{AQ062}, # crossing
    %w{AQ063}, # road intersection
    %w{AQ080 nam}, # ferry site
    %w{AQ090}, # entrance / exit
    %w{AQ125 nam}, # station
    %w{AQ135}, # vehicle stopping area
    %w{BH170}, # spring
    %w{BH503}, # hydrographic network node
    %w{BI029}, # dam
    %w{BI030}, # lock
    %w{GB005 nam}, # airport
    %w{ZD040 namn1} # named location
  ].each {|r|
  s += <<-EOS
  map.addLayer({
    'id': '#{r[0]}-pt', 'type': 'symbol',
    'source': 'globalmaps-vt', 'source-layer': 'pt#{r[0]}',
    'paint': {
      'text-color': #{r[2] ? '\'' + r[2] + '\'' : 'randomColor()'}
    },
    'layout': {
      'text-field': '#{r[1] ? '{' + r[1] + '}' : '*'}',
    }
  });
  EOS
  }
  s
end

def polygons
  s = ''
  [ # re-ordered for drawing
    %w{XX501 #ff0 0.1}, # landmask area
    %w{BA030}, # island
    %w{BA020 #e3f3f7 0.5}, # foreshore
    %w{FA001 #fffcdb 0.1}, # administrative area
    %w{BA040 #e3f3f7 0.8}, # water
    %w{BH000 #5494a8 0.8}, # inland water
    %w{BH080 #e3f3f7 0.8}, # lake / pond
    %w{BH130 #e3f3f7 0.8}, # reservoir
    %w{BJ030 #ccf 0.5}, # glacier
    %w{BJ100 #ccf 0.5}, # snow field
    %w{AL020 #f00 0.3}, # builtup area
  ].each {|r|
  s += <<-EOS
  map.addLayer({
    'id': '#{r[0]}-pg', 'type': 'fill',
    'source': 'globalmaps-vt', 'source-layer': 'pg#{r[0]}',
    'paint': {
      'fill-color': #{r[1] ? '\'' + r[1] + '\'' : 'randomColor()'},
      'fill-opacity': #{r[2] ? r[2] : 0.8}
    }
  });
  EOS
  }
  s
end

def mapboxgl(country, version)
  dst_path = "mapboxgl/#{country}#{version}.html"
  metadata = JSON::parse(File.read("../gm#{country}#{version}vt/metadata.json"))
  center = metadata['center']
  tiles_path = "https://globalmaps-vt.github.io/gm#{country}#{version}vt" +
    "/{z}/{x}/{y}.mvt"
  File.open(dst_path, 'w') {|w|
    w.print <<-EOS
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />
<title></title>
<meta name='viewport' content='initial-scale=1,maximum-scale=1,user-scalable=no' />
<script src='https://api.tiles.mapbox.com/mapbox-gl-js/v0.26.0/mapbox-gl.js'></script>
<link href='https://api.tiles.mapbox.com/mapbox-gl-js/v0.26.0/mapbox-gl.css' rel='stylesheet' />
<link href='https://www.mapbox.com/base/latest/base.css' rel='stylesheet' />
<style>
body { margin:0; padding:0; }
#map { position:absolute; top:0; bottom:0; width:100%; }
table { border-collapse: collapse; }
td { border: 1px solid #b9b9b9; }
</style>
</head>
<body>
<div id='map'></div>
<script>
mapboxgl.accessToken = 'pk.eyJ1IjoiaGZ1IiwiYSI6ImlRSGJVUTAifQ.rTx380smyvPc1gUfZv1cmw';
map = new mapboxgl.Map({
  container: 'map', style: 'mapbox://styles/mapbox/satellite-v9',
  center: [#{center[0]},  #{center[1]}], zoom: #{center[2]}, hash: true, maxZoom: 12
});
colors = [
  'FC49A3', 'CC66FF', '66CCFF', '66FFCC',
  '00FF00', 'FFCC66', 'FF6666', 'FF0000',
  'FF8000', 'FFFF66', '00FFFF'
];
function randomColor() {
  return '#' + colors[parseInt(Math.random() * colors.length)];
}
map.on('load', function () {
  map.addSource('globalmaps-vt', {
    tiles: ['#{tiles_path}'],
    type: 'vector', maxzoom: 8
  });
#{polygons}
#{lines}
#{points}
});
describe = function(f_code) {
  return '('  + {
    'AN010': 'railway',
    'AN500': 'raliway network link',
    'AP030': 'road',
    'AP050': 'trail',
    'AP500': 'road network link',
    'AQ040': 'bridge',
    'AQ070': 'ferry route',
    'AQ130': 'tunnel',
    'BA010': 'coastline',
    'BH140': 'river',
    'BH210': 'inland shoreline',
    'BH502': 'watercourse',
    'BI020': 'dam',
    'BI030': 'lock',
    'FA000': 'administrative boundary',
    'XX500': 'sea limit',

    'AL020': 'builtup area',
    'AL105': 'settlement',
    'AN060': 'railroad yard',
    'AP020': 'interchange',
    'AQ062': 'crossing',
    'AQ063': 'road intersection',
    'AQ080': 'ferry site',
    'AQ090': 'entrance / exit',
    'AQ125': 'station',
    'AQ135': 'vehicle stopping area',
    'BH170': 'spring',
    'BH503': 'hydrographic network node',
    'BI029': 'dam',
    'BI030': 'lock',
    'GB005': 'airport',
    'ZD040': 'named location',

    'AL020': 'builtup area',
    'BA020': 'foreshore',
    'BA030': 'island',
    'BA040': 'water',
    'BH000': 'inland water',
    'BH080': 'lake / pond',
    'BH130': 'reservoir',
    'BJ030': 'glacier',
    'BJ100': 'snow field',
    'FA001': 'administrative area',
    'XX501': 'landmask area'

  }[f_code] + ')';
}
map.on('click', function(e) {
  var features = map.queryRenderedFeatures(e.point, {
    //layers: ['FA001-pg']
  });
  if (!features.length) return;
  var s = features.length + ' features.<br/>';
  for(var i in features) {
    s += '<table><tr>'
    for(var j in features[i].properties) {
      var v = features[i].properties[j];
      s += "<td>" + j + ": " +
        v + (j == 'f_code' ? describe(v) : '') + "</td>";
    }
    s += '</tr></table>';
  }
  var popup = new mapboxgl.Popup()
    .setLngLat(map.unproject(e.point))
    .setHTML(s)
    .addTo(map);
});
</script>
</body>
</html>
    EOS
  }
end

def tangram(country, version)
end

Dir.glob('../*vt') {|path|
  next unless /^gm(.*?)(\d\d)vt$/.match File.basename(path)
  (country, version) = [$1, $2]
  mapboxgl(country, version)
  tangram(country, version)
}
