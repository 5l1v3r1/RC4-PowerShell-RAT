<?php
$key = "test";
$path = "/tmp/mimikatz.ps1";

class Crypt_Rc4 {
    private $s = array();
    private $i = 0;
    private $j = 0;
    private $_key;

    function Crypt_RC4($key = null) {
        if ($key != null) {
            $this->setKey($key);
        }
    }

    function setKey($key) {
        if (strlen($key) > 0)
            $this->_key = $key;
    }

    function key(&$key) {
        $len= strlen($key);
        for ($this->i = 0; $this->i < 256; $this->i++) {
            $this->s[$this->i] = $this->i;
        }
        $this->j = 0;

        for ($this->i = 0; $this->i < 256; $this->i++) {
            $this->j = ($this->j + $this->s[$this->i] + ord($key[$this->i % $len])) % 256;
            $t = $this->s[$this->i];
            $this->s[$this->i] = $this->s[$this->j];
            $this->s[$this->j] = $t;
        }
        $this->i = $this->j = 0;
    }

    function crypt(&$paramstr) {
        $this->key($this->_key);
        $len= strlen($paramstr);

        for ($c= 0; $c < $len; $c++) {
            $this->i = ($this->i + 1) % 256;
            $this->j = ($this->j + $this->s[$this->i]) % 256;
            $t = $this->s[$this->i];
            $this->s[$this->i] = $this->s[$this->j];
            $this->s[$this->j] = $t;
            $t = ($this->s[$this->i] + $this->s[$this->j]) % 256;
            $paramstr[$c] = chr(ord($paramstr[$c]) ^ $this->s[$t]);
        }
    }

    function decrypt(&$paramstr) {
        $this->crypt($paramstr);
    }
}

$c = new Crypt_Rc4($key);

$data = file_get_contents($path);
$c->crypt($data);
echo $data;
?>
