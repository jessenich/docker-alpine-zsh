#!/bin/pwsh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

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
    [Alias('-alpine-version')]
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