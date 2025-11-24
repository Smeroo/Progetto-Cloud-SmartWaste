import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // Create waste types
  console.log('Creating waste types...');
  const wasteTypes = await Promise.all([
    prisma.wasteType.create({
      data: {
        name: 'Plastica',
        description: 'Contenitori in plastica, bottiglie, flaconi',
        color: '#FFD700',
        iconName: 'recycle',
        disposalInfo: 'Svuotare e sciacquare i contenitori. Appiattire le bottiglie per ridurre il volume. Non inserire plastica sporca o con residui di cibo.',
        examples: 'Bottiglie di acqua e bibite, flaconi di shampoo e detersivi, vaschette per alimenti, sacchetti puliti, imballaggi in plastica',
      },
    }),
    prisma.wasteType.create({
      data: {
        name: 'Carta e Cartone',
        description: 'Giornali, riviste, scatole di cartone',
        color: '#0066CC',
        iconName: 'newspaper',
        disposalInfo: 'Appiattire le scatole per ottimizzare lo spazio. Non inserire carta sporca, oleata o plastificata. Rimuovere nastri adesivi e parti in plastica o metallo.',
        examples: 'Giornali, riviste, libri, quaderni, scatole di cartone, cartoni della pizza (se puliti), sacchetti di carta',
      },
    }),
    prisma.wasteType.create({
      data: {
        name: 'Vetro',
        description: 'Bottiglie e contenitori in vetro',
        color: '#228B22',
        iconName: 'wine-bottle',
        disposalInfo: 'Svuotare e sciacquare i contenitori. Non inserire ceramica, porcellana, specchi, lampadine o vetri di finestre.',
        examples: 'Bottiglie di vino, birra e acqua, vasetti di marmellata e conserve, contenitori in vetro per alimenti',
      },
    }),
    prisma.wasteType.create({
      data: {
        name: 'Organico',
        description: 'Scarti di cibo e rifiuti biodegradabili',
        color: '#8B4513',
        iconName: 'leaf',
        disposalInfo: 'Utilizzare sacchetti biodegradabili e compostabili. Non inserire liquidi in grande quantità, oli esausti o ossa di grandi dimensioni.',
        examples: 'Avanzi di cibo, bucce di frutta e verdura, fondi di caffè, filtri di tè, tovaglioli di carta sporchi, piccole ossa',
      },
    }),
    prisma.wasteType.create({
      data: {
        name: 'Indifferenziato',
        description: 'Rifiuti non riciclabili negli altri contenitori',
        color: '#808080',
        iconName: 'trash',
        disposalInfo: 'Conferire solo ciò che non può essere riciclato negli altri contenitori. Ridurre al minimo questa frazione differenziando correttamente.',
        examples: 'Pannolini e assorbenti, carta sporca o plastificata, ceramica e porcellana, giocattoli rotti, oggetti in gomma',
      },
    }),
    prisma.wasteType.create({
      data: {
        name: 'Metalli',
        description: 'Lattine, barattoli, piccoli oggetti metallici',
        color: '#C0C0C0',
        iconName: 'can-food',
        disposalInfo: 'Svuotare e sciacquare i contenitori. Separare eventuali parti non metalliche. Piccoli oggetti metallici vanno qui.',
        examples: 'Lattine di alluminio, barattoli metallici, coperchi, pentole e padelle, piccoli elettrodomestici (dove previsto)',
      },
    }),
  ]);

  console.log(`✅ Created ${wasteTypes.length} waste types`);

  // Create example users
  console.log('Creating users...');
  const hashedPassword = await bcrypt.hash('Password123!', 10);

  const citizen = await prisma.user.create({
    data: {
      email: 'mario.rossi@example.com',
      name: 'Mario',
      surname: 'Rossi',
      cellphone: '+39 333 1234567',
      role: 'USER',
      password: hashedPassword,
      oauthProvider: 'APP',
    },
  });

  const operatorUser = await prisma.user.create({
    data: {
      email: 'comune.roma@example.com',
      name: 'Comune',
      surname: 'di Roma',
      role: 'OPERATOR',
      password: hashedPassword,
      oauthProvider: 'APP',
      operator: {
        create: {
          organizationName: 'Comune di Roma - Ufficio Ambiente',
          vatNumber: 'IT12345678901',
          telephone: '+39 06 67101',
          website: 'https://www.comune.roma.it',
        },
      },
    },
  });

  console.log('✅ Created users');

  // Create collection points
  console.log('Creating collection points...');
  
  const ecoIsland1 = await prisma.collectionPoint.create({
    data: {
      name: 'Isola Ecologica Centro',
      operatorId: operatorUser.id,
      description: 'Centro di raccolta principale in zona centro. Accetta tutti i tipi di rifiuti differenziati. Personale disponibile per assistenza.',
      isActive: true,
      accessibility: 'Accessibile a persone con disabilità, ampio parcheggio disponibile',
      capacity: 'Grande - oltre 50 utenti/ora',
      address: {
        create: {
          street: 'Via Roma',
          number: '123',
          city: 'Roma',
          zip: '00100',
          country: 'Italia',
          latitude: 41.9028,
          longitude: 12.4964,
        },
      },
      wasteTypes: {
        connect: wasteTypes.map(wt => ({ id: wt.id })),
      },
      schedule: {
        create: {
          monday: true,
          tuesday: true,
          wednesday: true,
          thursday: true,
          friday: true,
          saturday: true,
          sunday: false,
          openingTime: '08:00',
          closingTime: '20:00',
          notes: 'Chiuso la domenica e nei giorni festivi',
        },
      },
    },
  });

  const streetBins = await prisma.collectionPoint.create({
    data: {
      name: 'Cassonetti Via Milano',
      operatorId: operatorUser.id,
      description: 'Postazione cassonetti stradali per raccolta differenziata. Svuotamento regolare 3 volte a settimana.',
      isActive: true,
      capacity: 'Media - 20-50 utenti/ora',
      address: {
        create: {
          street: 'Via Milano',
          number: '45',
          city: 'Roma',
          zip: '00184',
          country: 'Italia',
          latitude: 41.8919,
          longitude: 12.5113,
        },
      },
      wasteTypes: {
        connect: [
          { id: wasteTypes[0].id }, // Plastica
          { id: wasteTypes[1].id }, // Carta
          { id: wasteTypes[2].id }, // Vetro
          { id: wasteTypes[4].id }, // Indifferenziato
        ],
      },
      schedule: {
        create: {
          isAlwaysOpen: true,
          notes: 'Cassonetti stradali accessibili 24/7',
        },
      },
    },
  });

  const ecoIsland2 = await prisma.collectionPoint.create({
    data: {
      name: 'Centro Raccolta Quartiere Nord',
      operatorId: operatorUser.id,
      description: 'Centro di raccolta di quartiere con area dedicata ai rifiuti ingombranti e RAEE.',
      isActive: true,
      accessibility: 'Parcheggio disponibile, rampa di accesso',
      capacity: 'Media - 30 utenti/ora',
      address: {
        create: {
          street: 'Via Tiburtina',
          number: '200',
          city: 'Roma',
          zip: '00185',
          country: 'Italia',
          latitude: 41.9109,
          longitude: 12.5268,
        },
      },
      wasteTypes: {
        connect: wasteTypes.map(wt => ({ id: wt.id })),
      },
      schedule: {
        create: {
          monday: true,
          tuesday: false,
          wednesday: true,
          thursday: false,
          friday: true,
          saturday: true,
          sunday: false,
          openingTime: '09:00',
          closingTime: '18:00',
          notes: 'Aperto lunedì, mercoledì, venerdì e sabato',
        },
      },
    },
  });

  console.log('✅ Created 3 collection points');

  // Create example reports
  console.log('Creating example reports...');
  
  await prisma.report.create({
    data: {
      userId: citizen.id,
      collectionPointId: streetBins.id,
      type: 'FULL_BIN',
      description: 'Il cassonetto della plastica è completamente pieno e trabocca. Alcuni rifiuti sono caduti a terra.',
      status: 'PENDING',
    },
  });

  await prisma.report.create({
    data: {
      userId: citizen.id,
      collectionPointId: streetBins.id,
      type: 'NEEDS_CLEANING',
      description: 'Area intorno ai cassonetti sporca, necessita pulizia',
      status: 'IN_PROGRESS',
      resolvedBy: operatorUser.id,
    },
  });

  console.log('✅ Created example reports');

  console.log('🎉 Database seed completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error during seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
