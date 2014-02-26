<?php
class ATOS extends PaymentModule{
  private $_html = '';
  private $_postErrors = array();
  public function __construct(){
    $this->name = 'atos';
    $this->tab = 'Payment';
    $this->version = '1.3';
    parent::__construct();
    $this->page = basename(__FILE__, '.php');
    $this->displayName = $this->l('ATOS');
    $this->description = $this->l('Module de Paiement Bancaire SIPS/ATOS');
    $this->confirmUninstall = $this->l('&Ecirc;tes vous s&ocirc;r de vouloir supprimer vos details ?');
  }
  public function install(){
    if (!parent::install()
        OR !Configuration::updateValue('ATOS_NOMLOGO', '')
        OR !Configuration::updateValue('ATOS_MERCHAND_ID', '')
        OR !Configuration::updateValue('ATOS_BANK', '')
        OR !Configuration::updateValue('ATOS_BIN', '')
        OR !$this->registerHook('payment')){
        return false;
    }else{
        return true;
    }
  }
  public function uninstall(){
  	// désinstallation du module
    $conf = Configuration::getMultiple(array('ATOS_MERCHAND_ID'));
	if(is_file(dirname(__FILE__)."/param/pathfile")){
		$pathfile=dirname(__FILE__)."/param/pathfile";
		@unlink($pathfile);
	}
	if(is_file(dirname(__FILE__)."/param/parmcom.".$conf['ATOS_MERCHAND_ID'])){
		$comfile =dirname(__FILE__)."/param/parmcom.".$conf['ATOS_MERCHAND_ID'];
		@unlink($comfile);
	}
    if (!Configuration::deleteByName('ATOS_MERCHAND_ID')
        OR !Configuration::deleteByName('ATOS_NOMLOGO')
        OR !Configuration::deleteByName('ATOS_BANK')
        OR !Configuration::deleteByName('ATOS_BIN')
        OR !parent::uninstall()){
        return false;
    }else{
        return true;
    }
  }
  public function TrouveCertif(){
  	// liste des certificats présents dans le répertoire param, retoure les codes marchand
	$dir     = dirname(__FILE__)."/param/";
	$dossier = opendir($dir);
	while($fichier = readdir($dossier)){
		$non = array('.', '..');
		if(!in_array($fichier,$non)){
			$lien="$dir/$fichier";
			if(!is_dir($dir."/".$fichier) && strpos($fichier,'certif.fr.')!==false){
				$return[] = trim(str_replace('certif.fr.','',$fichier));
			}
		}
	}
	closedir($dossier);
	return $return;
  }
  public function VerifRepBin($dir=''){
	$conf = Configuration::getMultiple(array('ATOS_BIN'));
	if($dir=='' || $conf['ATOS_BIN']=='')
		$dir  = dirname(__FILE__)."/bin/";
	else{
		$dir  = $conf['ATOS_BIN'];
	}
	$dossier = opendir($dir);
	$return  = array();
	while($fichier = readdir($dossier)){
		$non = array('.', '..');
		if(!in_array($fichier,$non)){
			$lien="$dir/$fichier";
			if(!is_dir($dir."/".$fichier) && (strpos($fichier,'request')!==false || strpos($fichier,'response')!==false)){
				$return[] = trim($fichier);
			}
		}
	}
	closedir($dossier);
	$ret = false;
	if(!@empty($return) && count($return)>=2)
		$ret = true;
	return $ret;
  }
  public function GetTrasactionID(){
	$return = '';
    $TrasactionIDFile = dirname(__FILE__)."/log/transac.txt";
	$ContenuFile = '';
	$fp = fopen($TrasactionIDFile, 'r');
	if ($fp) {
		while (!feof($fp)) {
			$ContenuFile .= fgets($fp, 4096);
		}
		fclose($fp);
	}
	$TransactionIDs  = explode(';',$ContenuFile);
	$return = rand(1,999999);
	$stop = 'false';
	while($stop=='false'){
		if(in_array($return,$TransactionIDs) || in_array($return.'#STATUT1',$TransactionIDs)){
			$return = rand(1,999999);
		}else{
			$stop = 'true';
		}
	}
	$fp = fopen($TrasactionIDFile, "a");
	fwrite($fp,$return."#STATUT1;");
	fclose($fp);
	return $return;
  }
  public function updatefile($merchant_id,$BankServer,$nom_logo){
  	// fonction qui va écrire/réécrire le fichier /param/pathfile et /param/parmcom........
    $pathfile=dirname(__FILE__)."/param/pathfile";
    $comfile =dirname(__FILE__)."/param/parmcom.".$merchant_id;
    @unlink($pathfile);
    $fp=fopen($pathfile, "w");
	$return = true;
    if($fp){
          fwrite($fp,"DEBUG!NO!\n");
          fwrite($fp,"D_LOGO!".__PS_BASE_URI__."modules/".$this->name."/logo/!\n");
          fwrite($fp,"F_CERTIFICATE!param/certif!\n");
          fwrite($fp,"F_PARAM!param/parmcom!\n");
          fwrite($fp,"F_DEFAULT!param/parmcom.".str_replace('test','',str_replace('prod','',$BankServer))."!\n");
          fclose($fp);
          $fp=fopen($comfile, "w");
          if($fp){
            fwrite($fp,"LOGO!".$nom_logo."!\n");
			fwrite($fp,"AUTO_RESPONSE_URL!http://".$_SERVER['HTTP_HOST'].__PS_BASE_URI__."modules/".$this->name."/validation.php!\n");
            fwrite($fp,"CANCEL_URL!http://".$_SERVER['HTTP_HOST'].__PS_BASE_URI__."modules/".$this->name."/validation.php!\n");
            fclose($fp);
          }else{
			$return = false;
          }
    }else{
		  $return = false;
    }
	return $return;
  }
  public function getContent(){
  	// collecte des données, vérifications, enregistrement des paramètres du module
    $this->_html = '<h2>SIPS/ATOS Banque</h2>';
    if (isset($_POST['submitATOS'])){
	  $a_bin = str_replace('\\','/',$_POST['Atos_bin']);
	  $a_bin = str_replace('//','/',$a_bin.'/');
      if (empty($_POST['Atos_bin'])){
        $this->_postErrors[] = $this->l('Le r&eacute;pertoire des binaires est requis.');
	  }elseif(!@is_dir($a_bin)){
        $this->_postErrors[] = $this->l('Le r&eacute;pertoire des binaires n\'existe pas.');
	  }elseif(!ATOS::VerifRepBin($a_bin)){
        $this->_postErrors[] = $this->l('Le r&eacute;pertoire des binaires n\'est pas valide.');
	  }
      if (empty($_POST['BankServer']))
        $this->_postErrors[] = $this->l('La Banque est requise.');
      if (empty($_POST['nom_logo']))
        $this->_postErrors[] = $this->l('Le Nom du Logo du Marchand est requis.');
      if (empty($_POST['merchant_id']))
        $this->_postErrors[] = $this->l('Le Code Marchand est requis.');
	  $retour = ATOS::updatefile($_POST['merchant_id'],$_POST['BankServer'],$_POST['nom_logo']);
	  if($retour===false)
          $this->_postErrors[] = $this->l('Votre repertoire param n\'a pas les droits en &eacute;criture.');
      if (!sizeof($this->_postErrors)){
	    Configuration::updateValue('ATOS_BIN', $a_bin);
        Configuration::updateValue('ATOS_NOMLOGO', $_POST['nom_logo']);
        Configuration::updateValue('ATOS_MERCHAND_ID', $_POST['merchant_id']);
        Configuration::updateValue('ATOS_BANK', $_POST['BankServer']);
        $this->displayConf();
      }
      else
        $this->displayErrors();
    }
    $this->displayATOS();
    $this->displayFormSettings();
    return $this->_html;
  }
  public function displayConf(){
  	// affichage confirmation/infirmation prise en compte des changements
    $this->_html .= '
    <div class="conf confirm">
      <img src="../img/admin/ok.gif" alt="Confirmation" />
      Param&egrave;tres Sauvegard&eacute;s
    </div>';
  }
  public function displayErrors(){
  	// affichage des erreurs
    $nbErrors = sizeof($this->_postErrors);
    $this->_html .= '
    <div class="alert error">
      <h3>Il y a '.$nbErrors.' '.($nbErrors > 1 ? 'erreurs' : 'erreur').'</h3>
      <ol>';
    foreach ($this->_postErrors AS $error)
      $this->_html .= '<li>'.$error.'</li>';
    $this->_html .= '
      </ol>
    </div>';
  }
  public function displayATOS(){
    // affichage dans la liste des modules
    $this->_html .= '
    <img src="../modules/'.$this->name.'/atos.gif" style="float:left; margin-right:15px;" />
    <b>Ce module vous permet d\'accepter les paiements par SIPS/ATOS.</b><br /><br />
    Si le client choisis ce mode de paiement, votre compte bancaire SIPS/ATOS sera automatiquement cr&eacute;dit&eacute;.<br />
    Vous devez cr&eacute;er votre compte SIPS/ATOS aupr&egrave;s de votre agence bancaire avant de configurer ce module.<br />Les donn&eacute;es inscrites par d&eacute;faut sont ici des donn&eacute;es vous permettant de faire fonctionner le module en mode g&eacute;n&eacute;rique mais en aucun cas d\'accepter de r&eacute;els paiements.
    <br /><br /><br />';
  }
  public function displayFormSettings(){
  	// formulaire de configuration du module
	// récupération des données de la base
    $conf = Configuration::getMultiple(array('ATOS_MERCHAND_ID', 'ATOS_NOMLOGO', 'ATOS_BANK', 'ATOS_BIN'));
	// si on a rien écupéré ou que rien n'a été posté
    if(@empty($conf) && @empty($_POST)){
		// on initialise les valeurs par défaut pour le formulaire
		$Atos_bin     = str_replace('\\','/',dirname(__FILE__)).'/bin/';
		$merchant_id  = '014102450311111';
        $nom_logo     = 'merchant.gif';
        $BankServer   = 'hsbctest';
    	$checkhsbctest= ' checked';
    }elseif(!@empty($conf) && @empty($_POST)){
		// si on a rien posté mais trouvé ce qu'il faut dans la base
        if(empty($nom_logo))
          $nom_logo    = $conf['ATOS_NOMLOGO'];
        if(empty($merchant_id))
          $merchant_id = $conf['ATOS_MERCHAND_ID'];
        if(empty($BankServer))
          $BankServer  = $conf['ATOS_BANK'];
        if(empty($Atos_bin))
          $Atos_bin    = $conf['ATOS_BIN'];
    }elseif(!@empty($_POST)){
		// si on a posté on initialise les variables pour renseigner les champs du formulaire avec les posts
        if(empty($merchant_id))
          $merchant_id = $_POST['merchant_id'];
        if(empty($nom_logo))
          $nom_logo    = $_POST['nom_logo'];
        if(empty($BankServer))
          $BankServer  = $_POST['BankServer'];
        if(empty($Atos_bin))
          $Atos_bin    = $_POST['Atos_bin'];
    }
	// peut être pas utile : si on a toujours rien
    if(empty($Atos_bin))     $Atos_bin    = str_replace('\\','/',dirname(__FILE__)).'/bin/';
    if(empty($nom_logo))     $nom_logo    = 'merchant.gif';
    if(empty($merchant_id))  $merchant_id = '014102450311111';
    if(empty($BankServer)){
	    $BankServer   = 'hsbctest';
    	$checkhsbctest= ' checked';
	}
	// on recherche quel est le serveur à cocher dans le formulaire
    $checkhsbcprod         ='';
    $checkhsbctest         ='';
    $checkcyberplusprod    ='';
    $checkcyberplustest    ='';
    $checkelysnetprod      ='';
    $checkelysnettest      ='';
	$checketransactionsprod='';
    $checketransactionstest='';
    $checkmercanetprod     ='';
    $checkmercanettest     ='';
    $checkscelliusnetprod  ='';
    $checkscelliusnettest  ='';
    $checksherlocksprod    ='';
    $checksherlockstest    ='';
    $checksogenactifprod   ='';
    $checksogenactiftest   ='';
    $checkwebaffairesprod  ='';
    $checkwebaffairestest  ='';
    if(empty($BankServer)){
	    $BankServer   = 'hsbctest';
    	$checkhsbctest= ' checked';
    }else{
		if($BankServer=='hsbctest')
			$checkhsbctest 	        = ' checked';
		elseif($BankServer=='hsbcprod')
			$checkhsbcprod 	        = ' checked';
		elseif($BankServer=='cyberplustest')
			$checkcyberplustest     = ' checked';
		elseif($BankServer=='cyberplustprod')
			$checkcyberplusprod     = ' checked';
		elseif($BankServer=='elysnettest')
			$checkelysnettest       = ' checked';
		elseif($BankServer=='elysnetprod')
			$checkelysnetprod       = ' checked';
		elseif($BankServer=='etransactionstest')
			$checketransactionstest = ' checked';
		elseif($BankServer=='etransactionsprod')
			$checketransactionsprod = ' checked';
		elseif($BankServer=='mercanettest')
			$checkmercanettest      = ' checked';
		elseif($BankServer=='mercanetprod')
			$checkmercanetprod      = ' checked';
		elseif($BankServer=='scelliusnettest')
			$checkscelliusnettest   = ' checked';
		elseif($BankServer=='scelliusnetprod')
			$checkscelliusnetprod   = ' checked';
		elseif($BankServer=='sherlockstest')
			$checksherlockstest     = ' checked';
		elseif($BankServer=='sherlocksprod')
			$checksherlocksprod     = ' checked';
		elseif($BankServer=='sogenactiftest')
			$checksogenactiftest    = ' checked';
		elseif($BankServer=='sogenactifprod')
			$checksogenactifprod    = ' checked';
		elseif($BankServer=='webaffairestest')
			$checkwebaffairestest   = ' checked';
		elseif($BankServer=='webaffairesprod')
			$checkwebaffairesprod   = ' checked';
    }
	// récupération de la liste des certificats trouvés dans le répertoire param
	$certificat = ATOS::TrouveCertif();
	// tri pour l'affichage
	sort($certificat);
    $this->_html .= '
    <form action="'.$_SERVER['REQUEST_URI'].'" method="post">
    <fieldset>
      <legend><img src="../img/admin/contact.gif" />Configuration</legend>
      <label>Serveur bancaire :</label>
      <div class="margin-form">
	  <table><tr><td>
      <input type="radio" name="BankServer" value="hsbcprod" '.$checkhsbcprod.'/> HSBC Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="hsbctest" '.$checkhsbctest.'/> HSBC Test
	  </td></tr>
	  <tr><td>
      <input type="radio" name="BankServer" value="cyberplusprod" '.$checkcyberplusprod.'/> Banque Populaire Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="cyberplustest" '.$checkcyberplustest.'/> Banque Populaire Test
	  </td></tr>
	  <tr><td>
      <input type="radio" name="BankServer" value="elysnetprod" '.$checkelysnetprod.'/> CCF Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="elysnettest" '.$checkelysnettest.'/> CCF Test
	  </td></tr>
	  <tr><td>
      <input type="radio" name="BankServer" value="etransactionsprod" '.$checketransactionsprod.'/> Cr&eacute;dit Agricole Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="etransactionstest" '.$checketransactionstest.'/> Cr&eacute;dit Agricole Test
	  </td></tr>
	  <tr><td>
      <input type="radio" name="BankServer" value="mercanetprod" '.$checkmercanetprod.'/> BNP Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="mercanettest" '.$checkmercanettest.'/> BNP Test
	  </td></tr>
	  <tr><td>
      <input type="radio" name="BankServer" value="scelliusnetprod" '.$checkscelliusnetprod.'/> La Banque Postale Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="scelliusnettest" '.$checkscelliusnettest.'/> La Banque Postale Test
	  </td></tr>
	  <tr><td>
      <input type="radio" name="BankServer" value="sherlocksprod" '.$checksherlocksprod.'/> LCL Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="sherlockstest" '.$checksherlockstest.'/> LCL Test
	  </td></tr>
	  <tr><td>
      <input type="radio" name="BankServer" value="sogenactifprod" '.$checksogenactifprod.'/> Soci&eacute;t&eacute; G&eacute;n&eacute;rale Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="sogenactiftest" '.$checksogenactiftest.'/> Soci&eacute;t&eacute; G&eacute;n&eacute;rale Test
	  </td></tr>
	  <tr><td>
      <input type="radio" name="BankServer" value="webaffairesprod" '.$checkwebaffairesprod.'/> Cr&eacute;dit du Nord Production&nbsp;
      </td><td>
      <input type="radio" name="BankServer" value="webaffairestest" '.$checkwebaffairestest.'/> Cr&eacute;dit du Nord Test
	  </td></tr></table>
      </div>
	  <br />
      <label>Code Marchand :</label>
      <div class="margin-form"><select name="merchant_id" >';
	  for($i=0;$i<count($certificat);$i++){
	  	if(trim($merchant_id)==trim($certificat[$i])) $selected= ' selected="selected"';
		else $selected= '';
		$affplus = ' - Votre certificat bancaire';
		if(trim($certificat[$i])=='038862749811111') $affplus = ' - CyberPlus - Banque Populaire - D&eacute;mo';
		if(trim($certificat[$i])=='013044876511111') $affplus = ' - E-Transactions - Cr&eacute;dit Agricole - D&eacute;mo';
		if(trim($certificat[$i])=='014102450311111') $affplus = ' - ElysNet - CCF/HSBC - D&eacute;mo';
		if(trim($certificat[$i])=='082584341411111') $affplus = ' - Mercanet - BNP - D&eacute;mo';
		if(trim($certificat[$i])=='014141675911111') $affplus = ' - ScelliusNet - La Banque Postale - D&eacute;mo';
		if(trim($certificat[$i])=='014295303911111') $affplus = ' - Sherlocks - LCL - D&eacute;mo';
		if(trim($certificat[$i])=='014213245611111') $affplus = ' - Sogenactif - Soci&eacute;t&eacute; G&eacute;n&eacute;rale - D&eacute;mo';
		if(trim($certificat[$i])=='014022286611111') $affplus = ' - WebAffaires - Cr&eacute;dit du Nord - D&eacute;mo';
	    $this->_html .= '<option value="'.$certificat[$i].'"'.$selected.'>'.$certificat[$i].$affplus.'</option>';
      }
	  $this->_html .= '</select></div>
      <br />
      <label>Nom du Logo :</label>
      <div class="margin-form">
      <input type="text" name="nom_logo" size=55 maxlength=42 value="'.$nom_logo.'" />
      </div>
      <br />
      <label>R&eacute;pertoire des fichiers binaires :</label>
      <div class="margin-form">
      <input type="text" name="Atos_bin" size=55 maxlength=100 value="'.$Atos_bin.'" />
      </div>
      <br /><center><input type="submit" name="submitATOS" value="Sauvegarder les param&egrave;tres" class="button" /></center>
    </fieldset>
    </form><br /><br />
    <fieldset >
      <legend><img src="../img/admin/warning.gif" />Information</legend>
      Afin d\'utiliser votre module de paiement ATOS, vous devez demander &agrave; votre banque la cr&eacute;ation votre compte e-commerce ATOS.<br /><br />
      Choisissez le <i>Code Marchand</i> (liste des certificats pr&eacute;sents dans le r&eacute;pertoire param de votre module).<br />
      Entrez le <i>Nom du Logo</i>, que vous avez donn&eacute; &agrave; votre banque.<br />
      <br />
      S\'assurer que la fonction exec est bien autoris&eacute;e sur votre serveur par le php.ini.<br />
      Le r&eacute;pertoire /param/ doit &ecirc;tre ouvert en &eacute;criture. (chmod 666)<br />
      Les fichiers binaires (request et response) doivent &ecirc;tre ex&eacute;cutables (chmod 755).<br />
      Le fichier /log/logs.txt doit avoir les droits en &eacute;criture (chmod 666).<br />
      Le fichier /log/transac.txt doit avoir les droits en &eacute;criture (chmod 666).<br />
      D&eacute;posez votre certificat, fourni par votre banque, dans le r&eacute;pertoire param/ de votre module.<br />
      Ce certificat, devant se présenter sous la forme certif.fr.votrecodemarchand, viendra ajouter une ligne suppl&eacute;mentaire &agrave; choisir dans la liste des codes marchands valides pour le module.<br />
      Les certificats certif.fr....... sont pr&eacute;sent sur votre serveur '.$_SERVER['SERVER_SOFTWARE'].' pour effectuer les tests de bon fonctionnement du module avec les param&egrave;tres par d&eacute;faut.<br />
      Voici les Codes Marchands g&eacute;n&eacute;riques (et non les votres) correspondants aux différentes banques, si vous voulez tester le bon fonctionnement :<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;038862749811111 pour CyberPlus - Banque Populaire<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;014102450311111 pour ElysNet - CCF<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;013044876511111 pour E-Transactions - Crédit Agricole<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;014102450311111 pour ElysNet - HSBC<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;082584341411111 pour Mercanet - BNP<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;014141675911111 pour ScelliusNet - La Banque Postale<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;014295303911111 pour Sherlocks - LCL<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;014213245611111 pour Sogenactif - Soci&eacute;t&eacute; G&eacute;n&eacute;rale<br />
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;014022286611111 pour WebAffaires - Cr&eacute;dit du Nord<br />
      <br />
	  Les logos, marques et marques d&eacute;pos&eacute;es sont la propri&eacute;t&eacute; de leurs d&eacute;tenteurs respectifs.
      <br />
	  Module SIPS/ATOS pour Prestashop : <a href="https://sourceforge.net/forum/?group_id=246678" target="_blank">Forum</a> - <a href="https://sourceforge.net/projects/modatospresta/" target="_blank">T&eacute;l&eacute;chargements</a>.
	  </fieldset>';
  }

  public function hookPayment($params){
    // récupération des données pour l'affichage front office avec atos.tpl
    global $smarty;
    $conf                = Configuration::getMultiple(array('ATOS_MERCHAND_ID','ATOS_BANK'));
    $address             = new Address(intval($params['cart']->id_address_invoice));
    $customer            = new Customer(intval($params['cart']->id_customer));
    $id_currency         = intval($params['cart']->id_currency);
    $currency            = new Currency(intval($id_currency));
    $UrlCallRequest      = 'http://'.$_SERVER['HTTP_HOST'].__PS_BASE_URI__.'modules/'.$this->name.'/call_request.php';
    $transaction_id      = ATOS::GetTrasactionID();
    $montant  = number_format(Tools::convertPrice($params['cart']->getOrderTotal(true, 3),$currency),2,'.','');
    if(strpos($montant,'.')) $montant=$montant*100;
    $montant             = str_replace('.','',$montant);
    $BankServer          = str_replace('test','',str_replace('prod','',$conf['ATOS_BANK']));
    $smarty->assign(array(
      'UrlCallRequest' => $UrlCallRequest,
      'address'        => $address,
      'customer'       => $customer,
      'currency'       => $currency,
      'amount'         => $montant,
      'BankServer'     => $BankServer,
      'id_cart'        => intval($params['cart']->id),
      'transaction_id' => intval($transaction_id),
      'this_path'      => $this->_path
    ));
    return $this->display(__FILE__, 'atos.tpl');
    }
}

?>