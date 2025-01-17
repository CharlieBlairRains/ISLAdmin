$mailboxes = Get-Mailbox -ResultSize unlimited | Where-Object{$_.RecipientTypeDetails -ne "DiscoveryMailbox"}  
  
foreach ($mailbox in $mailboxes){  
    Get-MailboxPermission -Identity $mailbox.UserPrincipalName | Where-Object{$_.user -eq "ERoss@centreforsight.com"} | fl
}