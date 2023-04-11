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
            background-color: var(--body-background-colour);
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
            width: calc(100% - 40px);
            overflow-x: hidden;
        }
        #bk {
            position: fixed;
            z-index: 1;
            right: -20%;
            bottom: -20%;
            width: 70%;
        }
        #bk img {
            width: 100%;
        }
        main {
            position: absolute;
            width: calc(100% - 40px);
            top: 0;
            left: 0;
            z-index: 2;
            padding: 60px 20px 20px 20px;
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
        input {
            font-family: Helvetica, sans-serif;
            font-size: 14pt;
            padding: 10px;
        }
        input:focus {
            border:1px solid var(--input-border-colour);
            box-shadow: none;
            -moz-box-shadow: none;
            -webkit-box-shadow: none;
        }

        /* Buttons */
        button {
            color: var(--button-text-colour);
            font-family: 'subheading', Helvetica, sans-serif;
            font-size: 44pt;
            line-height: 34pt;
            padding: 10px 40px;
        }
        #quick-menu .button, #quick-menu-button .button, button {
            background-color: var(--button-background-colour);
            border: 3px solid var(--button-border-colour);
            cursor: pointer;
        }
        button:hover, #quick-menu .button:hover, #quick-menu-button .button:hover {
            background-color: var(--button-hover-background-colour);
        }

        /* Box */
        .box {
            min-width: 500px;
            min-height: 300px;
            border: 3px solid var(--box-border-colour);
            box-shadow: var(--box-shadow);
            background-color: var(--box-background-colour);
        }
        .box-body {
            padding: 20px;
        }
        .box-footer {
            padding: 20px;
            display: flex;
            align-content: flex-end;
            flex-flow: column wrap;
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

        /* Quick menu */
        #quick-menu-button {                
            position: fixed;
            right: 30px;
            bottom: 30px;
            z-index: 100;
            overflow: hidden;
        }
        #quick-menu {
            position: fixed;
            right: 55px;
            bottom: 140px;
            width: 80px;
            /*display: none;*/
            z-index: 101;
        }
        #quick-menu .button, #quick-menu-button .button {
            display: block;
            height: 100px;
            width: 100px;
            border-radius: 50%;
            text-align: center;
            vertical-align: middle;
            overflow: hidden;
            box-shadow: var(--button-shadow);
        }
        #quick-menu .button {
            margin-bottom: 10px;
        }
        #quick-menu img {
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
        .page-title span, .no-results span {
            background-color: var(--text-heading-background-colour);
            border: 3px solid var(--text-heading-border-colour);
            padding: 10px 40px 0 40px;
            box-shadow: var(--text-heading-shadow);
        }

        .page-title span {
            padding: 10px 40px 10px 40px;
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
            box-shadow: var(--box-shadow);
        }
        </style>";
    }
}