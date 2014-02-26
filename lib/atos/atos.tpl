<p class="payment_module">
    <a href="javascript:$('#atos_form').submit();" title="{l s='Payer par carte bancaire' mod='atos'}"><img src="{$module_template_dir}images/{$BankServer}.gif" alt="{l s='Payer par carte bancaire' mod='atos'}" />{l s='Payer par carte bancaire' mod='atos'}</a>
<form action="{$UrlCallRequest}" method="post" name="PaymentRequest" class="hidden" id="atos_form" target="_top">
    <input type="hidden" name="amount"                 value="{$amount}">
    <input type="hidden" name="id_cart"                value="{$id_cart}">
    <input type="hidden" name="transaction_id"         value="{$transaction_id}">
</form>
</p>
