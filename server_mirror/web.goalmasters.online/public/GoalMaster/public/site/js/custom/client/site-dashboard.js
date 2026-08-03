(function ($) {
    "use strict";
    $(document).ready(function () {
        activeLeftSideMenu();
    });

    function activeLeftSideMenu() {
        $('.leftside-menu ul li').each(function () {
            let href = $(this).find('a').attr('href');
            if (href == window.location.href) {
                $(this).addClass('left-side-nav-active');
            }
        });
    }
})(jQuery);