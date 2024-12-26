@echo off
flutter build web --release --base-href="/gpx/" & scp -Cr build\web chris@backstreets.site:gpx & title CMD