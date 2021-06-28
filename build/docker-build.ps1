#!/bin/pwsh

## MIT License
## 
## Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Build')]
param(
    [Parameter(
        Mandatory = $true,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        HelpMessage = 'Semantic version compliant string to tag built image with.'
    )]
    [Alias('i')]
    [Alias('-image-version')]
    [ValidateNotNullOrEmpty]
    [string]$ImageVersion,

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        HelpMessage = "Semantic version compliant string that coincides with underlying base Alpine image. See dockerhub.com/alpine for values. 'latest' is considered valid.")]
    [ALias('-alpine-version')]
    [string]$AlpineVersion = 'latest',

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        HelpMessage = 'GLibC Version to install during build process. Empty value will assume latest version unless -ExcludeGLibC is specified.')]
    [Alias('-glibc-version')]
    [string]$GLibCVersion = '8.1_p1-r0',

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        HelpMessage = 'Flag indicating whether to include accompanying documentation packages. Including docs will increase image size significantly.')]
    [Alias('-no-docs')]
    [Flag]$NoDocs = $false,

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        HelpMessage = 'Flag indicating whether glibc should be excluded entirely. Presence of this flag overrides version specified in -g | [--no-glibc]. Including glibc will increase image size significantly.')]
    [Alias('-no-glibc')]
    [Flag]$NoGLibC = $false,

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        HelpMessage = ('Registry which the image will be pushed upon successful build. If not using dockerhub, the full FQDN must be specified. ' +
            'This assumes the default docker daemon is already authenticated with the registry specified. If dockerhub is used, just the username is required. ' +
            'Default value: jessenich91.'))]
    [Alias('-registry')]
    [string]$Registry = 'jessenich91',

    [Parameter(
        Mandatory = $false,
        ValueFromPipeline = $false,
        ValueFromPipelineByPropertyName = $false,
        HelpMessage = "Repository which the image will be pushed upon successful build. Default value: 'alpine-zsh'")]
    [Alias('-repository')]
    [string]$Repository = 'alpine-zsh'
)

begin {
    if ([string]::IsNullOrWhiteSpace($ImageVersion)) {
        throw [System.ArgumentNullException]::new('ImageVersion');
    }

    if ($NoGLibC -and -not [string]::IsNullOrWhiteSpace($GLibCVersion)) {
        $GLibCVersion = $null;
    }

    $Script:Tag1 = 'latest';
    $Script:Tag2 = $ImageVersion;
    $Script:RepositoryRoot = '.';
}

process {
    if ($GLibCVersion -ne 'none') {
        $targetStage = 'glibc';

        if ($NoDocs) {
            $Script:Tag1 = 'no-docs-glibc-latest';
            $Script:Tag2 = "no-docs-glibc-$ImageVersion";
        }
        else {
            $Script:Tag1 = 'latest';
            $Script:Tag2 = "$ImageVersion";
        }
    }
    else {
        if ($NoDocs) {
            $Script:Tag1 = 'no-docs-latest';
            $Script:Tag2 = "no-docs-$ImageVersion";
        }
        else {
            $Script:Tag1 = 'no-glibc-latest';
            $Script:Tag2 = "no-glibc-$ImageVersion";
        }
    }

    docker buildx build `
        -f "$($Script:RepositoryRoot)/Dockerfile" `
        -t "$($Registry)/$($Repository):$($Script:Tag1)" `
        -t "$($Registry)/$($Repository):$($Script:Tag2)" `
        --build-arg "ALPINE_VERSION=$AlpineVersion" `
        --build-arg "NO_DOCS=$NO_DOCS" `
        --platform linux/arm/v7, linux/arm64/v8, linux/amd64 `
        --target $targetStage `
        --push `
        $Script:RepositoryRoot
}

end {

}