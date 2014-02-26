<?php
include(dirname(__FILE__).'/../../config/config.inc.php');
include(dirname(__FILE__).'/../../header.php');
$retour = 'index.php';
if(!@empty($_POST)){
	function verif_champ($post){
		$return      = false;
		$conf        = Configuration::getMultiple(array('ATOS_MERCHAND_ID'));
		$cookie      = new Cookie('ps');
		$id_cart     = $cookie->id_cart;
		$cart        = new Cart($id_cart);
		$id_currency = intval($cart->id_currency);
		$currency    = new Currency(intval($id_currency));
		$montant     = number_format(Tools::convertPrice($cart->getOrderTotal(true, 3), $currency), 2, '.', '');
		if(strpos($montant,'.'))  $montant =$montant*100;
		$montant     = str_replace('.','',$montant);
		if($post['merchant_id'] == $conf['ATOS_MERCHAND_ID'] &&	$post['amount']==$montant)
		  	$return = true;
		return $return;
    }
    function UpdateTrasactionIDFile($transaction_id,$type){
		if($transaction_id!=''){
			$TrasactionIDFile = dirname(__FILE__)."/log/transac.txt";
			$ContenuFile = '';
			$fp = fopen($TrasactionIDFile, 'r');
			if ($fp) {
				while (!feof($fp)) {
					$ContenuFile .= fgets($fp, 4096);
				}
				fclose($fp);
			}
			if($type=="fail")   $ContenuFile = str_replace($transaction_id."#STATUT1;","",$ContenuFile);
			elseif($type=="ok") $ContenuFile = str_replace($transaction_id."#STATUT1",$transaction_id,$ContenuFile);
			$fp = fopen($TrasactionIDFile, "w");
			fwrite($fp,$ContenuFile);
			fclose($fp);
		}
  	}
	include(dirname(__FILE__).'/atos.php');
	$ATOS        = new ATOS();
	$cookie      = new Cookie('ps');
	$conf        = Configuration::getMultiple(array('ATOS_MERCHAND_ID','ATOS_BIN','ATOS_BANK'));
	$message     = "message=$_POST[DATA]";
	$pathfile    = "pathfile=".dirname(__FILE__)."/param/pathfile";
	$path_bin 	 = $conf['ATOS_BIN']."response";
	$result      = exec("$path_bin $pathfile $message");
	$tableau     = explode ("!", $result);
	$tableau[22] = $cookie->id_cart;
	$cart        = new Cart(intval($tableau[22]));
	$logfile     = dirname(__FILE__)."/log/logs.txt";
	$fp = fopen($logfile, "a");
	fwrite($fp,"Transaction ".$conf['ATOS_BANK']." du : ".date("d/m/Y H:i:s",time())."\n");
	if(($tableau[1]=="")&&($tableau[2]=="")){
		UpdateTrasactionIDFile($tableau[6],'fail');
		fwrite($fp,"erreur appel response\n");
		fwrite($fp,"executable response non trouve $path_bin\n");
		fwrite($fp, "-------------------------------------------\n");
		fclose($fp);
	}elseif($tableau[1]!=0){
		UpdateTrasactionIDFile($tableau[6],'fail');
		fwrite($fp," API call error.\n");
		fwrite($fp,"Error message :  $tableau[2]\n");
		fwrite($fp, "-------------------------------------------\n");
		fclose($fp);
		$ATOS->validateOrder($tableau[22],_PS_OS_ERROR_,0, $ATOS->displayName,'Transaction ATOS '.$tableau[2]);
	} elseif(Validate::isLoadedObject($cart) && $cart->OrderExists() == 0 && $tableau[18]=='05') {
		UpdateTrasactionIDFile($tableau[6],'fail');
		$ATOS->validateOrder($tableau[22],_PS_OS_ERROR_,0, $ATOS->displayName,'Transaction ATOS '.$tableau[2]);
		fwrite($fp,"Error message :  $tableau[2]\n");
		fwrite($fp,"merchant_id : $tableau[3]\n");
		fwrite($fp,"merchant_country : $tableau[4]\n");
		fwrite($fp,"amount : $tableau[5]\n");
		fwrite($fp,"transaction_id : $tableau[6]\n");
		fwrite($fp,"transmission_date: $tableau[8]\n");
		fwrite($fp,"payment_means: $tableau[7]\n");
		fwrite($fp,"payment_time : $tableau[9]\n");
		fwrite($fp,"payment_date : $tableau[10]\n");
		fwrite($fp,"response_code : $tableau[11]\n");
		fwrite($fp,"payment_certificate : $tableau[12]\n");
		fwrite($fp,"authorisation_id : $tableau[13]\n");
		fwrite($fp,"currency_code : $tableau[14]\n");
		fwrite($fp,"card_number : $tableau[15]\n");
		fwrite($fp,"cvv_flag: $tableau[16]\n");
		fwrite($fp,"cvv_response_code: $tableau[17]\n");
		fwrite($fp,"bank_response_code: $tableau[18]\n");
		fwrite($fp,"complementary_code: $tableau[19]\n");
		fwrite($fp,"complementary_info: $tableau[20]\n");
		fwrite($fp,"return_context: $tableau[21]\n");
		fwrite($fp,"caddie : $tableau[22]\n");
		fwrite($fp,"receipt_complement : $tableau[23]\n");
		fwrite($fp,"merchant_language : $tableau[24]\n");
		fwrite($fp,"language : $tableau[25]\n");
		fwrite($fp,"customer_id : $tableau[26]\n");
		fwrite($fp,"order_id : $tableau[27]\n");
		fwrite($fp,"customer_email : $tableau[28]\n");
		fwrite($fp,"customer_ip_address : $tableau[29]\n");
		fwrite($fp,"capture_day : $tableau[30]\n");
		fwrite($fp,"capture_mode : $tableau[31]\n");
		fwrite($fp,"data : $tableau[32]\n");
		fwrite($fp, "Resultat : Paiement refuse\n");
		fwrite($fp, "-------------------------------------------\n");
		$retour = 'history.php';
		fclose($fp);
	} elseif(Validate::isLoadedObject($cart) && $cart->OrderExists() == 0 && $tableau[18]=='00') {
		fwrite($fp,"merchant_id : $tableau[3]\n");
		fwrite($fp,"merchant_country : $tableau[4]\n");
		fwrite($fp,"amount : $tableau[5]\n");
		fwrite($fp,"transaction_id : $tableau[6]\n");
		fwrite($fp,"transmission_date: $tableau[8]\n");
		fwrite($fp,"payment_means: $tableau[7]\n");
		fwrite($fp,"payment_time : $tableau[9]\n");
		fwrite($fp,"payment_date : $tableau[10]\n");
		fwrite($fp,"response_code : $tableau[11]\n");
		fwrite($fp,"payment_certificate : $tableau[12]\n");
		fwrite($fp,"authorisation_id : $tableau[13]\n");
		fwrite($fp,"currency_code : $tableau[14]\n");
		fwrite($fp,"card_number : $tableau[15]\n");
		fwrite($fp,"cvv_flag: $tableau[16]\n");
		fwrite($fp,"cvv_response_code: $tableau[17]\n");
		fwrite($fp,"bank_response_code: $tableau[18]\n");
		fwrite($fp,"complementary_code: $tableau[19]\n");
		fwrite($fp,"complementary_info: $tableau[20]\n");
		fwrite($fp,"return_context: $tableau[21]\n");
		fwrite($fp,"caddie : $tableau[22]\n");
		fwrite($fp,"receipt_complement : $tableau[23]\n");
		fwrite($fp,"merchant_language : $tableau[24]\n");
		fwrite($fp,"language : $tableau[25]\n");
		fwrite($fp,"customer_id : $tableau[26]\n");
		fwrite($fp,"order_id : $tableau[27]\n");
		fwrite($fp,"customer_email : $tableau[28]\n");
		fwrite($fp,"customer_ip_address : $tableau[29]\n");
		fwrite($fp,"capture_day : $tableau[30]\n");
		fwrite($fp,"capture_mode : $tableau[31]\n");
		fwrite($fp,"data : $tableau[32]\n");
		$post['merchant_id']    = $tableau[3];
		$post['amount']         = $tableau[5];
		$post['transaction_id'] = $tableau[6];
		if(verif_champ($post)){
			UpdateTrasactionIDFile($post['transaction_id'],'ok');
			$valide = "paiement valide";
			$retour = 'history.php';
			$tableau[5] = number_format(intval($tableau[5])/100, 2, '.', '');
			$ATOS->validateOrder($tableau[22],_PS_OS_PAYMENT_,$tableau[5],$ATOS->displayName,'Transaction ATOS');
		}else{
			UpdateTrasactionIDFile($post['transaction_id'],'fail');
			$valide = "paiement invalide !";
			$retour = 'order.php';
			$ATOS->validateOrder($tableau[22],_PS_OS_ERROR_,0, $ATOS->displayName,'Transaction ATOS '.$tableau[2]);
		}
		fwrite($fp, "Resultat : ".$valide."\n");
		fwrite($fp, "-------------------------------------------\n");
		fclose($fp);
		print ("<BR><CENTER>".strtoupper($valide)."</CENTER><BR>");
	}else{
		UpdateTrasactionIDFile($tableau[6],'fail');
		fwrite($fp,$_POST['PAIEMENT']."\n");
		fwrite($fp, "-------------------------------------------\n");
		fclose($fp);
		print ("<BR><CENTER>".$_POST['PAIEMENT']."</CENTER><BR>");
	}
}
echo '<meta http-equiv="refresh" content="0; url=http://'.$_SERVER['HTTP_HOST'].__PS_BASE_URI__.$retour.'" />';
include(dirname(__FILE__).'/../../footer.php');
?>