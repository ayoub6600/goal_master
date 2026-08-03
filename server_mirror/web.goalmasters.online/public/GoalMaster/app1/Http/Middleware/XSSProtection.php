<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Routing\Redirector;
use App\Http\Controllers\HomeController;
use Illuminate\Support\Facades\Auth;

class XSSProtection
{
    /**
     * The following method loops through all request input and strips out all tags from
     * the request. This to ensure that users are unable to set ANY HTML within the form
     * submissions, but also cleans up input.
     *
     * @param Request $request
     * @param callable $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {

        if (!in_array(strtolower($request->method()), ['put', 'post', 'patch'])) {
            return $next($request);
        }

        $input = $request->all();

        array_walk_recursive($input, function (&$input) use ($request) {
            if ($request->route()->getName() == 'website.save.or.update.terms.condition') {
                $allowTag = "<a>, <acronym>, <address>, <abbr>, <applet>, <area>, <article>, <aside>, <audio>, <b>, <base>, <basefont>, <bdi>, <bdo>, <bgsound>, <big>, <blink>, <blockquote>, <body>, </br>, <br>, <button>, <canvas>, <caption>, <center>, <cite>, <code>, <col>, <colgroup>, <content>, <data>, <datalist>, <dd>, <decorator>, <del>, <details>, <dfn>, <dir>, <div>, <dl>, <dt>, <element>, <em>, <embed>, <fieldset>, <figcaption>, <figure>, <font>, <footer>, <form>, <frame>, <frameset>, <h1>, <h2>, <h3>, <h4>, <h5>, <h6>, <head>, <header>, <hgroup>, <hr>, <html>, <i>, <iframe>, <img>, <input>, <ins>, <isindex>, <kbd>, <keygen>, <label>, <legend>, <li>, <link>, <listing>, <main>, <map>, <mark>, <marquee>, <menu>, <menuitem>, <meta>, <meter>, <nav>, <nobr>, <noframes>, <object>, <ol>, <optgroup>, <option>, <output>, <p>, <param>, <plaintext>, <pre>, <progress>, <q>, <rp>, <rt>, <ruby>, <s>, <samp>, <section>, <select>, <shadow>, <small>, <source>, <spacer>, <span>, <strike>, <strong>, <style>, <sub>, <summary>, <sup>, <table>, <tbody>, <td>, <template>, <textarea>, <tfoot>, <th>, <thead>, <time>, <title>, <tr>, <track>, <tt>, <u>, <ul>, <var>, <video>, <wbr>,<xmp>";
                $input = strip_tags($input, $allowTag);
            } else {
                $input = htmlentities($input, ENT_QUOTES, 'UTF-8', false);
            }
        });

        $request->merge($input);
        
        return $next($request);
    }
}
