function Get-FreeDriveLetter {
    $usedLetters = (Get-PSDrive -PSProvider FileSystem).Name
    $allLetters = [char[]]([int][char]'G'..[int][char]'Y')
    $free = $allLetters | Where-Object { $usedLetters -notcontains $_ } | Select-Object -First 1
    return $free
}

$shares = @(
    '\\P-MADSI-MGAU\temp'
    '\\P-MADSI-MGAU\LabelJoy'
)

$ZLetter = 'Z'

foreach ($SPath in $shares) {

    $existingDrive = Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue |
                     Where-Object { $_.DisplayRoot -and $_.DisplayRoot.TrimEnd('\') -eq $SPath.TrimEnd('\') }

    if ($existingDrive) {
        Write-Host "Share $SPath is already mapped to drive $($existingDrive.Name):"
        Continue
        Exit 0
    }

    $used = (Get-PSDrive -PSProvider FileSystem).Name
    if ($used -notcontains $ZLetter) {
        $DriveLetter = $ZLetter
    } else {
        $DriveLetter = Get-FreeDriveLetter
    }

    if ($DriveLetter) {
        New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $SPath -Persist -ErrorAction Stop
        Write-Host "Mapped $SPath to drive $DriveLetter`:"
        Continue
        Exit 0
    } else {
        Write-Host "No free drive letters available to map $SPath."
        Exit 1001
    }
}