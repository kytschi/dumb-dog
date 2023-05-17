/**
 * Dumb Dog security helper
 *
 * @package     DumbDog\Helper\Security
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
namespace DumbDog\Helper;

use DumbDog\Exceptions\Exception;

class Security
{
    private cfg;

    public function __construct(object cfg)
    {
        let this->cfg = cfg;
    }

    public function clean(string str)
    {
        return filter_var(rawurldecode(str), FILTER_SANITIZE_STRING);
    }

    public function decrypt(str)
    {
        if (empty(this->cfg->encryption)) {
            throw new Exception("Invalid encryption key in config");
        }

        if (empty(str)) {
            return str;
        }

        var key, iv, token, splits;

        let splits = explode("::", str);
        let str = splits[0];
        let iv = hex2bin(splits[1]);
        let key = openssl_digest(this->cfg->encryption, "SHA256", true);
        let token = openssl_decrypt(str, "aes128", key, 0, iv);
    
        return token;
    }

    public function encrypt(string str)
    {
        if (empty(this->cfg->encryption)) {
            throw new Exception("Invalid encryption key in config");
        }

        if (empty(str)) {
            return str;
        }

        var key, iv, token;

        let key = openssl_digest(this->cfg->encryption, "SHA256", true);
        let iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length("aes128"));
        let token = openssl_encrypt(str, "aes128", key, 0, iv) . "::" . bin2hex(iv);
    
        return token;
    }
}