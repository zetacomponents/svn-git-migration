<?php

$template = array(
    "type" => "library",
    "homepage" => "https =>//github.com/zetacomponents",
    "authors" => array(),
    "license" => "apache2",
    "autoload" => array("classmap" => array("src")),
);

$zetaRoot = $argv[1];

foreach (scandir($argv[1]) AS $name) {
    $dir = $zetaRoot . "/" . $name;
    $name = dashify($name);
    if ( ! is_dir($dir) || in_array($name, array(".", ".."))) {
        continue;
    }

    $data = $template;
    $data["name"] = "zetacomponents/" . strtolower($name);

    $descriptionFile = $dir . "/DESCRIPTION";
    $data['description'] = $data['name'] . " Component";
    if (file_exists($descriptionFile)) {
        $data['description'] = trim(str_replace("\n", " ", file_get_contents($descriptionFile)));
    }

    $creditsFile = $dir . "/CREDITS";
    if (file_exists($creditsFile)) {
        foreach (file($creditsFile) as $line) {
            if (strpos($line, "- ") !== false) {
                $author = substr($line, 2);
                $data['authors'][] = array('name' => trim($author));
            }
        }
    }

    $json = json_encode($data);
    $json = shell_exec("echo " . escapeshellarg($json) . "|python -msimplejson.tool");
    file_put_contents(__DIR__ . "/composer/nodeps/" . strtolower($name) . ".json", $json);

    $data['require']['zetacomponents/base'] = '1.8';

    $deps = $dir . "/DEPS";
    if (file_exists($deps)) {
        foreach (file($deps) as $depsLine) {
            list($component, $version) = array_map('trim', explode(":", $depsLine));
            $data['require']['zetacomponents/' . strtolower($component)] = $version;
        }
    }

    $json = json_encode($data);
    $json = shell_exec("echo " . escapeshellarg($json) . "|python -msimplejson.tool");
    file_put_contents(__DIR__ . "/composer/deps/" . strtolower($name) . ".json", $json);
}

function dashify($word)
{
    return strtolower(preg_replace('~(?<=\\w)([A-Z])~', '-$1', $word));
}

