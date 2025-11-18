import 'package:flutter/material.dart';

import '../widgets/landing_bullet.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Politika privatnosti'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/app'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.labelLarge,
            ),
            child: const Text('Pokreni aplikaciju'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Politika privatnosti – Paušal kalkulator',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ova politika privatnosti objašnjava kako Paušal kalkulator koristi i štiti podatke kada se korisnik prijavi putem Google naloga i poveže svoj Google Sheets dokument radi obračuna i praćenja poslovanja.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Podaci kojima pristupamo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                const LandingBullet(
                  icon: Icons.person_outline,
                  title: 'Google nalog (openid)',
                  description:
                      'Koristimo “openid” dozvolu kako bismo vas bezbedno prijavili u aplikaciju i povezali vaš nalog sa jedinstvenim identifikatorom koji dobijamo od Google-a. Ne koristimo i ne čuvamo vašu e-mail adresu za potrebe aplikacije.',
                ),

                const LandingBullet(
                  icon: Icons.table_chart_outlined,
                  title: 'Google Sheets fajl koji izaberete',
                  description:
                      'Aplikacija koristi Google Picker i “drive.file” dozvolu kako bi vam omogućila da ručno izaberete konkretan Google Sheets fajl. Nakon toga Paušal kalkulator koristi Google Sheets API kako bi čitao vrednosti ćelija, dodavao nove redove, ažurirao određene opsege i čistio opsege isključivo u tom dokumentu (npr. prihodi, troškovi, klijenti). Aplikacija nema pristup drugim dokumentima na vašem Google nalogu.',
                ),

                const SizedBox(height: 24),

                const Text(
                  'Google API dozvole (scopes)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  'Paušal kalkulator koristi sledeće Google API dozvole koje su neophodne za rad aplikacije:\n\n'
                  '• openid – za bezbednu prijavu korisnika.\n'
                  '• https://www.googleapis.com/auth/spreadsheets – za čitanje i ažuriranje sadržaja Google Sheets dokumenta (čitanje opsega, dodavanje redova, ažuriranje i brisanje opsega ćelija).\n'
                  '• https://www.googleapis.com/auth/drive.file – za izbor konkretnog fajla na Google Drive-u putem Google Picker-a.\n\n'
                  'Ne koristimo dozvole “email” niti druge osetljive ili ograničene Google API dozvole koje nisu neophodne za funkcionisanje aplikacije. Pristup ograničavamo isključivo na dokument koji korisnik ručno odabere i na opsege koje aplikacija ažurira radi obračuna podataka.',
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Kako koristimo podatke',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  'Pristup Google nalogu i odabranom Google Sheets dokumentu koristimo isključivo da bismo:\n\n'
                  '• omogućili prijavu u aplikaciju,\n'
                  '• pročitali podatke iz odabranog Sheets fajla radi obračuna i prikaza u aplikaciji,\n'
                  '• upisali nove unose, dodali redove, očistili određene opsege i ažurirali samo potrebne delove dokumenta radi ažurnog vođenja evidencije.\n\n'
                  'Ne koristimo vaše Google podatke za oglašavanje, marketing ili pravljenje korisničkih profila. '
                  'Ne prodajemo i ne iznajmljujemo vaše podatke trećim stranama i ne koristimo podatke iz Google Drive/Sheets fajlova za obučavanje opštih AI/ML modela.',
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Čuvanje, zaštita i deljenje podataka',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  'Sadržaj vaših Google Sheets dokumenata ostaje u okviru vašeg Google naloga. Aplikacija te podatke čita “na zahtev” i, po potrebi, kratkotrajno kešira radi performansi. '
                  'Takvi podaci se čuvaju najkraće moguće vreme i zaštićeni su odgovarajućim tehničkim merama (HTTPS/TLS, kontrola pristupa itd.).\n\n'
                  'Podatke ne delimo sa trećim stranama osim sa pouzdanim tehničkim provajderima (npr. hosting), i to isključivo u meri u kojoj je neophodno za rad aplikacije, uz ugovornu obavezu zaštite podataka.',
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Vaša prava i brisanje podataka',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  'Pristup aplikaciji možete opozvati u bilo kom trenutku preko stranice vašeg Google naloga:\n'
                  'https://myaccount.google.com/permissions\n\n'
                  'Takođe, možete nam se obratiti ukoliko želite da obrišemo podatke koji se čuvaju u okviru same aplikacije (npr. lokalne konfiguracije). '
                  'Nakon potvrde identiteta, obrišaćemo ili anonimizovati podatke, osim onih koje smo zakonski obavezni da zadržimo (npr. knjigovodstvena evidencija).',
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Pitanja i kontakt',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                Text(
                  'Ako imate pitanja u vezi sa politikom privatnosti ili načinom na koji aplikacija obrađuje podatke, možete nas kontaktirati na:',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),

                SelectableText(
                  'office@finaccons.rs',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Poslednje ažuriranje: 14.11.2025.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}