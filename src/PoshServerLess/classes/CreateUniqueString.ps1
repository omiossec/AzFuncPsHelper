function CreateUniqueString ([int] $BufferSize= 10) {
    $randomArray = ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $BufferSize  | ForEach-Object {[char]$_})

    return -join $randomArray
}