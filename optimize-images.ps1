Add-Type -AssemblyName System.Drawing

$assetsDir = "C:\Users\TecoGamer\Desktop\cadubarber\assets"

# name (no ext) -> [maxLongEdge, jpegQuality]
$targets = @{
    "barba-cib2uszc"        = @(1100, 75)
    "colorido-bx1wnofi"     = @(1100, 75)
    "corte-social-czt28ewz" = @(1100, 75)
    "freestyle-dl3q8yo_"    = @(1100, 75)
    "luzes-cpzomh6r"        = @(1100, 75)
    "platinado-xlkou5hi"    = @(1100, 75)
    "reflexo-c6r5bpti"      = @(1100, 75)
    "tintura-d_ubx_yv"      = @(1100, 75)
    "home-mobile-cva6mcvx"  = @(1400, 80)
    "homecadu-cqi_4amr"     = @(1920, 80)
    "linha-c2hvm2vw"        = @(1920, 78)
    "tols-ddhaintb"         = @(1920, 75)
}

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }

function Resize-ToJpeg {
    param($srcPath, $dstPath, $maxLongEdge, $quality)

    $src = [System.Drawing.Image]::FromFile($srcPath)
    try {
        $scale = [Math]::Min(1.0, $maxLongEdge / [Math]::Max($src.Width, $src.Height))
        $newW = [int]([Math]::Round($src.Width * $scale))
        $newH = [int]([Math]::Round($src.Height * $scale))

        $bmp = New-Object System.Drawing.Bitmap($newW, $newH)
        $bmp.SetResolution($src.HorizontalResolution, $src.VerticalResolution)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $g.DrawImage($src, 0, 0, $newW, $newH)
        $g.Dispose()

        $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
        $bmp.Save($dstPath, $jpegCodec, $encParams)
        $bmp.Dispose()
    }
    finally {
        $src.Dispose()
    }
}

$results = @()
foreach ($name in $targets.Keys) {
    $maxEdge, $quality = $targets[$name]
    $srcFile = Get-ChildItem "$assetsDir\$name.*" | Select-Object -First 1
    if (-not $srcFile) { Write-Warning "Nao encontrado: $name"; continue }

    $oldSize = $srcFile.Length
    $dstPath = Join-Path $assetsDir "$name.jpg"
    $tmpPath = Join-Path $assetsDir "$name.jpg.tmp"

    Resize-ToJpeg -srcPath $srcFile.FullName -dstPath $tmpPath -maxLongEdge $maxEdge -quality $quality

    if ($srcFile.Extension -ne ".jpg") {
        Remove-Item $srcFile.FullName -Force
    } else {
        Remove-Item $srcFile.FullName -Force
    }
    Move-Item $tmpPath $dstPath -Force

    $newSize = (Get-Item $dstPath).Length
    $results += [PSCustomObject]@{
        Name    = $name
        OldMB   = [math]::Round($oldSize/1MB,2)
        NewMB   = [math]::Round($newSize/1MB,2)
    }
}

$results | Format-Table -AutoSize
"Total old: {0} MB -> Total new: {1} MB" -f ([math]::Round(($results.OldMB | Measure-Object -Sum).Sum,2)), ([math]::Round(($results.NewMB | Measure-Object -Sum).Sum,2))
