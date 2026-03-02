pkgname=save-music
pkgver=1.0.1
pkgrel=2

arch=(any)

depends=(curl ffmpeg)

package() {
  install -d "$pkgdir/usr"
  cp -r save-music/{bin,share} "$pkgdir/usr"
}

source=(git+https://github.com/Cricarvbnm/save-music.git)
sha256sums=('SKIP')
