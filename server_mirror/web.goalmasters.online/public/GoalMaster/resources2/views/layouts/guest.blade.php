<!DOCTYPE html>
<html lang="en">

<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta content='width=device-width, initial-scale=1.0, shrink-to-fit=no' name='viewport' />
    <meta name="_token" content="{{ csrf_token() }}" url="{{ url('/') }}" />
    <title>{{$appearance->app_name}} | Admin</title>
    <link rel="shortcut icon" href="{{url($appearance->icon)}}">

    <!-- Fonts and icons -->
    <script src="{{ dsAsset('js/lib/assets/js/plugin/webfont/webfont.min.js') }}"></script>
    <script>
        WebFont.load({
            google: {
                "families": ["Cairo:300,400,700,900"]
            },
            custom: {
                "families": ["Cairo", "Font Awesome 5 Solid", "Font Awesome 5 Regular",
                    "Font Awesome 5 Brands", "simple-line-icons"
                ],
                urls: ["{{ url('/') }}/js/lib/assets/css/fonts.min.css"]
            },
            active: function() {
                sessionStorage.fonts = true;
            }
        });

    </script>

    <!-- CSS Files -->
    <link href="{{ dsAsset('js/lib/assets/css/atlantis.min.css') }}" rel="stylesheet" />
    <link href="{{ dsAsset('css/site.css') }}" rel="stylesheet" />
    <link href="{{ dsAsset('js/lib/assets/css/bootstrap.min.css') }}" rel="stylesheet" />
    <script src="{{ dsAsset('js/lib/assets/js/core/jquery-3.6.0.min.js') }}"></script>

</head>

<body>

    <div class="content">
        @yield('content')
    </div>




    <!--   Core JS Files   -->
    <script src="{{ dsAsset('js/lib/assets/js/core/bootstrap.min.js') }}"></script>
</body>

</html>
