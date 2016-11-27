File.open('mapboxgl/left.html', 'w') {|w|
  w.print <<-EOS
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />
<title>Global Maps in binary bector tiles</title>
<style>
body { margin:0; padding:0; }
</style>
</head>
<body>
<ul>
  EOS

  Dir.glob('mapboxgl/*.html') {|path|
    /(.*?)(\d\d)/.match(File.basename(path, '.html'))
w.print <<-EOS
<li><a target='right' href='#{$1}#{$2}.html'>#{$1} #{$2.to_f / 10}</a></li>
EOS
  }

  w.print <<-EOS
</ul>
</body>
</html>
  EOS
}

File.open('mapboxgl/index.html', 'w') {|w|
  w.print <<-EOS
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8' />
<title>Global Maps in binary bector tiles</title>
<style>
body { margin:0; padding:0; }
iframe {
  position: absolute
  top: 0; left: 0; width: 100%; height: 100%;
}
</style>
</head>
<body>
<div style='position: absolute; width: 20%; height: 100%'>
  <iframe name='left' src='left.html' frameborder='0'></iframe>
</div>
<div style='position: absolute; right: 0px; width: 80%; height: 100%'>
  <iframe name='right' src='jp22.html' frameborder='0'></iframe>
</div>
</body>
</html>
  EOS
}
