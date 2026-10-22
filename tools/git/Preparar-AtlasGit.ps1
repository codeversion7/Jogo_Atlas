<#
Diagnostica o projeto ATLAS. -Aplicar configura apenas Git local e fetch.
Nao faz stage, merge, commit, checkout, push ou alteracoes globais.
Compativel por intencao com Windows PowerShell 5.1 e PowerShell 7.
Execucao no Windows ainda precisa ser validada no ambiente dos responsaveis.
#>
[CmdletBinding()]
param(
    [string]$CaminhoProjeto = '.',
    [switch]$Aplicar,
    [string]$NomeGit,
    [string]$EmailGit
)

$ErrorActionPreference = 'Stop'
$destinoEsperado = 'https://github.com/codeversion7/Jogo_Atlas.git'
$destinosValidos = @(
    'https://github.com/codeversion7/Jogo_Atlas.git',
    'https://github.com/codeversion7/Jogo_Atlas',
    'git@github.com:codeversion7/Jogo_Atlas.git',
    'ssh://git@github.com/codeversion7/Jogo_Atlas.git'
)

function Invoke-AtlasGit {
    param([string[]]$Argumentos)
    & git @Argumentos
    if ($LASTEXITCODE -ne 0) {
        throw ('Git falhou: ' + ($Argumentos -join ' '))
    }
}

Get-Command git -ErrorAction Stop | Out-Null
$pasta = Get-Item -LiteralPath (Resolve-Path -LiteralPath $CaminhoProjeto).Path
if (-not $pasta.PSIsContainer) { throw 'CaminhoProjeto precisa ser uma pasta.' }
if (-not (Test-Path -LiteralPath (Join-Path $pasta.FullName 'project.godot') -PathType Leaf)) {
    throw 'project.godot nao encontrado. Abra a raiz real do jogo antes de preparar Git.'
}

Push-Location -LiteralPath $pasta.FullName
try {
    Invoke-AtlasGit -Argumentos @('--version')
    Write-Host ('Projeto: ' + $pasta.FullName)
    $cursor = $pasta
    $raizDetectada = $null
    while ($null -ne $cursor) {
        if (Test-Path -LiteralPath (Join-Path $cursor.FullName '.git')) {
            $raizDetectada = $cursor.FullName
            break
        }
        $cursor = $cursor.Parent
    }
    if ($raizDetectada -and $raizDetectada -ne $pasta.FullName) {
        throw 'A pasta pertence a um repositorio pai. Confira a raiz; nada foi inicializado.'
    }
    if (-not $raizDetectada) {
        if (-not $Aplicar) {
            Write-Host 'Git nao inicializado nesta raiz. -Aplicar pode inicializar e configurar origin.'
            return
        }
        Invoke-AtlasGit -Argumentos @('init')
    }

    $raizGit = ((& git rev-parse --show-toplevel) -join '').Trim()
    if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel consultar a raiz Git.' }
    if ((Resolve-Path -LiteralPath $raizGit).Path -ne $pasta.FullName) {
        throw 'A raiz Git diverge da raiz do projeto. Confira antes de continuar.'
    }
    Invoke-AtlasGit -Argumentos @('status', '--short', '--branch')

    $remotos = @(& git remote)
    if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel listar os remotos.' }
    if ($remotos -contains 'origin') {
        $urls = @(& git remote get-url --all origin)
        if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel consultar origin.' }
        foreach ($url in $urls) {
            if ($destinosValidos -cnotcontains $url.Trim()) {
                throw 'Origin aponta para outro destino. O script nao o substituiu.'
            }
        }
        $pushUrls = @(& git remote get-url --push --all origin)
        if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel consultar o destino de push.' }
        foreach ($url in $pushUrls) {
            if ($destinosValidos -cnotcontains $url.Trim()) {
                throw 'O destino de push diverge do projeto. O script nao o substituiu.'
            }
        }
        Write-Host 'Origin corresponde a codeversion7/Jogo_Atlas.'
    }
    elseif ($Aplicar) {
        Invoke-AtlasGit -Argumentos @('remote', 'add', 'origin', $destinoEsperado)
    }
    else {
        Write-Host 'Origin ausente; sera acrescentado somente com -Aplicar.'
    }

    if ($Aplicar) {
        if ($NomeGit) { Invoke-AtlasGit -Argumentos @('config', '--local', 'user.name', $NomeGit) }
        if ($EmailGit) { Invoke-AtlasGit -Argumentos @('config', '--local', 'user.email', $EmailGit) }
        $preferencias = @{
            'fetch.prune' = 'true'
            'pull.ff' = 'only'
            'push.default' = 'simple'
        }
        foreach ($chave in $preferencias.Keys) {
            $existente = & git config --get $chave
            if ($LASTEXITCODE -eq 1) {
                Invoke-AtlasGit -Argumentos @('config', '--local', $chave, $preferencias[$chave])
            }
            elseif ($LASTEXITCODE -ne 0) { throw ('Falha ao ler configuracao: ' + $chave) }
        }
        Invoke-AtlasGit -Argumentos @('fetch', 'origin')
    }

    foreach ($campo in @('user.name', 'user.email')) {
        $valor = & git config --get $campo
        if ($LASTEXITCODE -eq 1 -or [string]::IsNullOrWhiteSpace(($valor -join ''))) {
            Write-Warning ($campo + ' ausente. Defina com valores reais antes de fazer commits.')
        }
        elseif ($LASTEXITCODE -ne 0) { throw ('Falha ao consultar ' + $campo) }
        else { Write-Host ($campo + ': configurado (valor preservado).') }
    }

    Write-Host 'Diagnostico concluido. Consulte docs/desenvolvimento/GIT_E_CODEX.md para integrar os historicos.'
    Write-Host 'Nenhum arquivo foi staged; nenhum merge, commit ou push foi executado.'
}
finally {
    Pop-Location
}
