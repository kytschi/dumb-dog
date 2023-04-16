/**
 * Dumb Dog style builder
 *
 * @package     DumbDog\Ui\Style
 * @author 		Mike Welsh
 * @copyright   2023 Mike Welsh
 * @version     0.0.1
 *
 * Copyright 2023 Mike Welsh
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
 * Boston, MA  02110-1301, USA.
*/
namespace DumbDog\Ui;

class Style
{
    public function __construct(array cfg = [])
    {
        //
    }

    public function build()
    {
        return this->defaultStyle();
    }

    private function defaultStyle()
    {
        return "<style>
        @import url('/assets/style.css');
        html, body {
            color: var(--body-text-colour);
            font-family: Helvetica, sans-serif;
            font-size: 56pt;
            height: 100vh;
            width: 100%;
            margin: 0;
            padding: 0;
            overflow-x: hidden;
        }
        body {
            display: flex;
            flex-direction: row;
            align-items: flex-start;
            width:100%;
            overflow-x: hidden;
        }
        #bk {
            background-color: #92ddd6;
            background-image: url('/assets/bk.png');
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-position: bottom -100px right -240px;
        }
        #page-bk {
            background-color: #C3C4C6;
            background-image: url('/assets/pages-bk.jpg?sds');
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-position: bottom -220px right -140px;
        }
        #dashboard-bk {
            background-color: #92ddd6;
            background-image: url('/assets/dashboard-bk.jpg');
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-position: bottom -220px right -140px;
        }
        #settings-bk {
            background-color: #C7D9E5;
            background-image: url('/assets/settings-bk.jpg');
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-position: bottom -220px right -140px;
        }
        #templates-bk {
            background-color: #597566;
            background-image: url('/assets/templates-bk.jpg');
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-position: bottom -220px right -140px;
        }
        #themes-bk {
            background-color: #B4B5BA;
            background-image: url('/assets/themes-bk.jpg');
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-position: bottom -220px right -140px;
        }
        #users-bk {
            background-color: #f5ded6;
            background-image: url('/assets/users-bk.jpg');
            background-repeat: no-repeat;
            background-attachment: fixed;
            background-position: bottom -220px right -140px;
        }
        main {
            position: relative;
            margin: 0 auto;
            width: 100%;
            max-width: 1200px;
            z-index: 2;
            padding: 60px 0px;
        }

        /* Inputs */
        .input-group {
            display: flex;
            flex-direction: column;
            flex: 100%;
            margin-bottom: 30px;
        }
        .input-group span {
            font-family: 'subheading', Helvetica, sans-serif;
            line-height: 44pt;
        }
        input, textarea, select {
            font-family: Helvetica, sans-serif;
            font-size: 14pt;
            padding: 10px;
        }
        input:focus, textarea:focus, select:focus {
            border:1px solid var(--input-border-focus-colour);
            outline: none;
            box-shadow: none;
            -moz-box-shadow: none;
            -webkit-box-shadow: none;
        }
        .switcher {
            font-size: 0pt !important;
        }
        .switcher label * {
            vertical-align: middle;
            overflow: hidden;
        }
        .switcher input {
            display: none;
        }
        .switcher label input + span {
            position: relative;
            display: inline-block;
            margin-right: 10px;
            width: 100px;
            height: 38.2px;
            background-color: #fff;
            border:1px solid var(--input-border-colour);
            transition: all 0.3s ease-in-out;
        }
        .switcher label input + span small {
            position: absolute;
            display: block;
            width: 50%;
            height: 100%;
            overflow: hidden;
            cursor: pointer;
            background-color: var(--button-background-colour-disabled);
            transition: all .15s ease;
            box-shadow: none;
            font-size: 12px;
            font-weight: 600;
            text-align: center;
            user-select: none;
        }
        .switcher label input:checked + span {
            background-color: #fff;
        }
        .switcher label input:checked + span small {
            background-color: var(--button-background-colour);
            left: 50%;
        }
        .switcher label input:checked + span .switcher-off {
            display: none;
        }
        .switcher label input:checked + span .switcher-on {
            display: block;
        }

        /* Buttons */
        button, .default-item, .button-blank  {
            color: var(--button-text-colour);
            font-family: 'subheading', Helvetica, sans-serif;
            font-size: 44pt;
            line-height: 34pt;
        }
        button, .button-blank {
            padding: 10px 40px;
        }
        .default-item {
            vertical-align: middle;
            padding: 30px 0px 0px 0px;
        }
        .button, button, .button-blank {
            background-color: var(--button-background-colour);
            border: 3px solid var(--button-border-colour);
            cursor: pointer;
            text-decoration: none;
        }
        .button-blank {
            background: none !important;
            border: 0 !important;
        }
        button:hover, .button:hover {
            background-color: var(--button-hover-background-colour);
        }
        .button-blank:hover {
            color: var(--button-hover-background-colour);
        }
        .page-toolbar {
            display: flex;
            margin-bottom: 20px;
        }
        .page-toolbar .button {
            margin-right: 20px;
        }
        .round {
            height: 100px !important;
            width: 100px !important;
            border-radius: 50%;
            text-align: center;
            vertical-align: middle;
            padding: 0 !important;
            font-size: 0pt !important;
            background-color: var(--button-background-colour);
            border: 3px solid var(--button-border-colour);
            cursor: pointer;
        }
        .round img {
            margin-top: 20px;
            width: 60px;
        }

        /* Box */
        .box {
            width: 100%;
            border: 3px solid var(--box-border-colour);
            box-shadow: var(--box-shadow);
            background-color: var(--box-background-colour);
            margin-bottom: 40px;
        }
        .box-body {
            padding: 40px 40px;
        }
        .box-footer {
            padding: 0 40px 40px 40px;
            display: flex;
            justify-content: flex-end;
        }
        .box-footer a, .box-footer button {
            margin-left: 20px;
        }
        .box-title {
            background-color: var(--box-title-background-colour);
            padding: 20px;
            display: flex;
            flex-direction: row;
            border-bottom: 3px solid var(--box-title-border-colour);
            font-size: 48pt;
            font-weight: bold;
            font-family: 'heading', Helvetica, sans-serif;
        }
        .box-title img {
            width: 80px;
            margin-right: 10px;
        }
        .error .box-body, .success .box-body {
            font-family: 'subheading', Helvetica, sans-serif;
            text-transform: uppercase;
        }
        .error .box-body p, .success .box-body p {
            padding: 0;
            margin: 0;
        }

        /* Quick menu */
        #quick-menu-button {                
            position: fixed;
            right: 30px;
            top: 30px;
            z-index: 100;
        }
        #quick-menu {
            position: fixed;
            right: 55px;
            top: 140px;
            width: 80px;
            z-index: 101;
        }
        #quick-menu .button, #quick-menu-button .button, .page-toolbar .button {
            display: block;
            height: 100px;
            width: 100px;
            border-radius: 50%;
            text-align: center;
            vertical-align: middle;
            overflow: hidden;
            box-shadow: var(--button-shadow);
        }
        #quick-menu .button, .page-toolbar .button  {
            margin-bottom: 10px;
        }
        #quick-menu img, .page-toolbar img {
            margin-top: 20px;
            width: 60px;
        }
        #quick-menu-button img {
            margin-top: 22px;
            width: 80px;
        }

        /* Text */
        h1, h2, h3, h4, h5, h6 {
            font-family: 'subheading', Helvetica, sans-serif;
            margin: 20px 0 50px 0;
        }
        h1 {
            font-size: 78pt;
            line-height: 78pt;
        }
        h2 {
            font-size: 56pt;
            line-height: 56pt;
        }
        .page-title span, .no-results span, .page-sub-title span {                
            background-color: var(--text-heading-background-colour);
            border: 3px solid var(--text-heading-border-colour);
            padding: 10px 40px 0 40px;
            box-shadow: var(--text-heading-shadow);
            background-repeat: no-repeat;
            background-position: 20px 20px;
        }
        .page-title span {
            padding: 0px 40px 10px 100px;
        }
        .page-sub-title span {
            padding: 20px 40px;
        }
        .required {
            padding-top: 10px;
            color: var(--text-required-colour);
        }

        /* Sizes */
        .wfull {
            width: 100%;
        }

        /* Tiles */
        @media only screen and (min-width: 480px) {
            #tiles {
                -moz-column-count: 2;
                -webkit-column-count: 2;
                column-count: 2;
            }
        }

        @media only screen and (min-width: 768px) {
            #tiles {
                -moz-column-count: 2;
                -webkit-column-count: 2;
                column-count: 2;
            }
        }

        @media only screen and (min-width: 960px) {
            #tiles {
                -moz-column-count: 3;
                -webkit-column-count: 3;
                column-count: 3;
            }
        }

        #tiles {
            column-gap: 40px;
        }

        .tile {
            display: inline-block;
            break-inside: avoid-column;
            margin: 0 0 40px 0;
            width: 100%;
        }
        </style>";
    }
}