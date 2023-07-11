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
        return filter_var(rawurldecode(str), FILTER_SANITIZE_FULL_SPECIAL_CHARS);
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

    /**
     * Generate a random string.
     */
     public function randomString(
        int length = 64,
        string keyspace = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    ) {
        /*
         * If the length is less than one, throw an error.
         */
        if (length < 1) {
            throw new \Exception("Length must be a positive integer");
        }

        /*
         * Define the pieces array.
         */
        var pieces = [], max, iLoop = 0, key;

        /*
         * Generate a max length passed on the keyspace.
         */
        let max = mb_strlen(keyspace, "8bit") - 1;

        /*
         * Loop through and build pieces.
         */
        while (iLoop < length) {
            let key = random_int(0, max);
            let pieces[] = substr(keyspace, key, 1);
            let iLoop += 1;
        }

        /*
         * Implode the pieces and return the random string.
         */
        return implode("", pieces);
    }

    public function uuid()
    {
        var data;
        let data = random_bytes(16);
            
        let data[6] = chr(ord(data[6]) & 0x0f | 0x40);
        let data[8] = chr(ord(data[8]) & 0x3f | 0x80);
        return vsprintf("%s%s-%s-%s-%s-%s%s%s", str_split(bin2hex(data), 4));
        
    }
}