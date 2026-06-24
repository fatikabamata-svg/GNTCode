const API_BASE_URL = window.GNT_API_BASE_URL || 'http://localhost:3000';
const destinationsGrid = document.querySelector('#destinations-grid');
const destinationsStatus = document.querySelector('#destinations-status');
const regionFilter = document.querySelector('#region-filter');
const destinationSearch = document.querySelector('#destination-search');
const reservationForm = document.querySelector('#reservation-form');
const reservationDestination = document.querySelector('#reservation-destination');
const reservationStatus = document.querySelector('#reservation-status');

const fallbackDestinations = [
  {
    id: 1,
    name: 'Île de Room',
    slug: 'ile-de-room',
    type: 'île',
    region: 'Boké',
    shortDescription: 'Une escapade côtière idéale pour valoriser les richesses naturelles et culturelles de la région de Boké.',
    verificationStatus: 'pending',
    featured: true,
  },
  {
    id: 2,
    name: 'Fouta Djallon',
    slug: 'fouta-djallon',
    type: 'plateau / région',
    region: 'Moyenne Guinée',
    shortDescription: 'Des reliefs majestueux, des cascades et une atmosphère fraîche au cœur d’une région emblématique.',
    verificationStatus: 'verified',
    featured: true,
  },
  {
    id: 3,
    name: 'Ville de Conakry',
    slug: 'ville-de-conakry',
    type: 'ville',
    region: 'Conakry',
    shortDescription: 'La capitale guinéenne réunit patrimoine, culture urbaine, bord de mer et points d’intérêt incontournables.',
    verificationStatus: 'verified',
    featured: true,
  },
  {
    id: 4,
    name: 'Mont Nimba et crapauds géants',
    slug: 'mont-nimba-et-crapauds-geants',
    type: 'réserve / montagne',
    region: 'Guinée forestière',
    shortDescription: 'Un site naturel remarquable associé à une biodiversité rare et aux paysages de la Guinée forestière.',
    verificationStatus: 'verified',
    featured: true,
  },
];

let destinations = [];

const setStatus = (element, message, state = '') => {
  if (!element) return;
  element.textContent = message;
  element.dataset.state = state;
};

const getDestinationImageClass = (destination) => {
  const text = `${destination.slug || ''} ${destination.type || ''}`.toLowerCase();
  if (text.includes('fouta') || text.includes('plateau')) return 'highlands';
  if (text.includes('conakry') || text.includes('ville')) return 'city';
  if (text.includes('nimba') || text.includes('montagne') || text.includes('réserve')) return 'mountain';
  return 'island';
};

const createDestinationCard = (destination) => {
  const article = document.createElement('article');
  article.className = 'destination-card';
  article.dataset.destinationId = destination.id || '';

  const image = document.createElement('div');
  image.className = `card-image ${getDestinationImageClass(destination)}`;
  if (destination.imageUrl) {
    image.style.backgroundImage = `linear-gradient(180deg, transparent, rgba(0, 0, 0, 0.22)), url("${destination.imageUrl}")`;
  }

  const content = document.createElement('div');
  content.className = 'card-content';

  const meta = document.createElement('div');
  meta.className = 'card-meta';

  const badge = document.createElement('span');
  badge.className = destination.verificationStatus === 'verified' ? 'badge badge-verified' : 'badge badge-featured';
  badge.textContent = destination.verificationStatus === 'verified' ? 'Vérifié' : 'À vérifier';

  const region = document.createElement('span');
  region.className = 'destination-region';
  region.textContent = destination.region || 'Guinée';

  const title = document.createElement('h3');
  title.textContent = destination.name;

  const type = document.createElement('p');
  type.className = 'destination-type';
  type.textContent = destination.type || 'Destination';

  const description = document.createElement('p');
  description.textContent = destination.shortDescription || destination.longDescription || 'Une destination phare à découvrir avec Guinea National Tour.';

  const reserveButton = document.createElement('button');
  reserveButton.className = 'card-link card-button';
  reserveButton.type = 'button';
  reserveButton.textContent = 'Réserver';
  reserveButton.addEventListener('click', () => selectDestinationForReservation(destination));

  meta.append(badge, region);
  content.append(meta, title, type, description, reserveButton);
  article.append(image, content);
  return article;
};

const renderDestinations = () => {
  if (!destinationsGrid) return;
  const regionValue = regionFilter?.value || '';
  const searchValue = (destinationSearch?.value || '').toLowerCase().trim();
  const filteredDestinations = destinations.filter((destination) => {
    const matchesRegion = !regionValue || destination.region === regionValue;
    const searchable = `${destination.name || ''} ${destination.region || ''} ${destination.type || ''} ${destination.shortDescription || ''}`.toLowerCase();
    return matchesRegion && (!searchValue || searchable.includes(searchValue));
  });

  destinationsGrid.replaceChildren();
  filteredDestinations.forEach((destination) => destinationsGrid.append(createDestinationCard(destination)));

  if (filteredDestinations.length) {
    setStatus(destinationsStatus, `${filteredDestinations.length} destination(s) affichée(s).`, 'success');
  } else {
    setStatus(destinationsStatus, 'Aucune destination ne correspond à ces filtres.', 'warning');
  }
};

const populateDestinationControls = () => {
  const uniqueRegions = [...new Set(destinations.map((destination) => destination.region).filter(Boolean))].sort();
  if (regionFilter) {
    regionFilter.replaceChildren(new Option('Toutes les régions', ''));
    uniqueRegions.forEach((region) => regionFilter.add(new Option(region, region)));
  }

  if (reservationDestination) {
    reservationDestination.replaceChildren(new Option('Choisir une destination', ''));
    destinations.forEach((destination) => {
      reservationDestination.add(new Option(destination.name, destination.id));
    });
  }
};

const loadDestinations = async () => {
  setStatus(destinationsStatus, 'Chargement des destinations...', 'loading');
  const response = await fetch(`${API_BASE_URL}/api/v1/destinations?active=true&limit=100`);
  if (!response.ok) {
    throw new Error(`API destinations indisponible (${response.status})`);
  }
  const payload = await response.json();
  return Array.isArray(payload.data) ? payload.data : [];
};

const selectDestinationForReservation = (destination) => {
  if (reservationDestination && destination.id) {
    reservationDestination.value = String(destination.id);
  }
  document.querySelector('#reservation')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  setStatus(reservationStatus, `Destination sélectionnée : ${destination.name}.`, 'success');
};

const buildReservationPayload = () => {
  const formData = new FormData(reservationForm);
  return {
    destinationId: formData.get('destinationId') ? Number(formData.get('destinationId')) : null,
    bookingType: formData.get('bookingType'),
    travelDate: formData.get('travelDate'),
    travelersCount: Number(formData.get('travelersCount') || 1),
    guestFullName: formData.get('guestFullName'),
    guestEmail: formData.get('guestEmail'),
    guestPhone: formData.get('guestPhone'),
    notes: formData.get('notes'),
  };
};

const submitReservation = async (event) => {
  event.preventDefault();
  setStatus(reservationStatus, 'Envoi de votre demande...', 'loading');

  const response = await fetch(`${API_BASE_URL}/api/v1/reservations`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(buildReservationPayload()),
  });

  const payload = await response.json();
  if (!response.ok) {
    const details = Array.isArray(payload.errors) ? ` ${payload.errors.join(' ')}` : '';
    throw new Error(`${payload.message || 'La réservation a échoué.'}${details}`);
  }

  reservationForm.reset();
  setStatus(reservationStatus, 'Merci ! Votre demande de réservation a bien été enregistrée.', 'success');
};

const init = async () => {
  regionFilter?.addEventListener('change', renderDestinations);
  destinationSearch?.addEventListener('input', renderDestinations);
  reservationForm?.addEventListener('submit', (event) => {
    submitReservation(event).catch((error) => setStatus(reservationStatus, error.message, 'error'));
  });

  try {
    destinations = await loadDestinations();
  } catch (error) {
    console.warn(error.message);
    destinations = fallbackDestinations;
    setStatus(destinationsStatus, 'API indisponible : affichage des destinations de démonstration.', 'warning');
  }

  populateDestinationControls();
  renderDestinations();
};

document.addEventListener('DOMContentLoaded', init);
