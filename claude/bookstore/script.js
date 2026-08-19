const DEBOUNCE_DELAY_MS = 300;
const MAX_INPUT_LENGTH  = 100;
const API_ENDPOINT      = '/api/books';
const PLACEHOLDER_IMG   = 'https://via.placeholder.com/120x180?text=No+Cover';

const MOCK_BOOKS = [
  { id: 1,  title: 'The Hobbit',                       author: 'J.R.R. Tolkien',    price: '$12.99', coverUrl: 'https://via.placeholder.com/120x180?text=The+Hobbit' },
  { id: 2,  title: 'Harry Potter and the Sorcerer\'s Stone', author: 'J.K. Rowling', price: '$10.99', coverUrl: 'https://via.placeholder.com/120x180?text=Harry+Potter' },
  { id: 3,  title: 'The Lord of the Rings',             author: 'J.R.R. Tolkien',    price: '$18.99', coverUrl: 'https://via.placeholder.com/120x180?text=LOTR' },
  { id: 4,  title: 'To Kill a Mockingbird',             author: 'Harper Lee',         price: '$9.99',  coverUrl: 'https://via.placeholder.com/120x180?text=Mockingbird' },
  { id: 5,  title: 'Pride and Prejudice',               author: 'Jane Austen',        price: '$7.99',  coverUrl: 'https://via.placeholder.com/120x180?text=Pride' },
  { id: 6,  title: '1984',                              author: 'George Orwell',      price: '$8.99',  coverUrl: 'https://via.placeholder.com/120x180?text=1984' },
  { id: 7,  title: 'The Great Gatsby',                  author: 'F. Scott Fitzgerald', price: '$8.49', coverUrl: 'https://via.placeholder.com/120x180?text=Gatsby' },
  { id: 8,  title: 'Brave New World',                   author: 'Aldous Huxley',      price: '$9.49',  coverUrl: 'https://via.placeholder.com/120x180?text=Brave+New+World' },
  { id: 9,  title: 'The Catcher in the Rye',            author: 'J.D. Salinger',      price: '$10.49', coverUrl: 'https://via.placeholder.com/120x180?text=Catcher' },
  { id: 10, title: 'Fahrenheit 451',                    author: 'Ray Bradbury',       price: '$8.99',  coverUrl: 'https://via.placeholder.com/120x180?text=Fahrenheit' },
];

let allBooks = [];

function debounce(fn, delay) {
  let timer;
  return function (...args) {
    clearTimeout(timer);
    timer = setTimeout(() => fn.apply(this, args), delay);
  };
}

async function fetchBooks() {
  try {
    const response = await fetch(API_ENDPOINT);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    allBooks = await response.json();
  } catch {
    console.warn('API unavailable, using mock data');
    allBooks = MOCK_BOOKS;
  }
}

function searchBooks(query) {
  const trimmed = query.trim().slice(0, MAX_INPUT_LENGTH);
  if (trimmed === '') {
    renderResults(allBooks);
    return;
  }
  const lower = trimmed.toLowerCase();
  const filtered = allBooks.filter(book =>
    book.title.toLowerCase().includes(lower)
  );
  renderResults(filtered);
}

function renderResults(books) {
  const resultsEl  = document.getElementById('results');
  const emptyEl    = document.getElementById('empty-state');
  const template   = document.getElementById('book-card-template');

  resultsEl.innerHTML = '';

  if (books.length === 0) {
    emptyEl.hidden  = false;
    resultsEl.hidden = true;
    return;
  }

  emptyEl.hidden   = true;
  resultsEl.hidden = false;

  books.forEach(book => {
    const card  = template.content.cloneNode(true);
    const img   = card.querySelector('.book-cover');
    const title = card.querySelector('.book-title');
    const author = card.querySelector('.book-author');
    const price = card.querySelector('.book-price');

    img.src = book.coverUrl || PLACEHOLDER_IMG;
    img.alt = book.title;
    img.onerror = () => { img.src = PLACEHOLDER_IMG; };

    title.textContent  = book.title;
    author.textContent = book.author;
    price.textContent  = book.price;

    resultsEl.appendChild(card);
  });
}

async function init() {
  await fetchBooks();
  renderResults(allBooks);

  const input     = document.getElementById('search-input');
  const searchBtn = document.getElementById('search-btn');
  const debouncedSearch = debounce(() => searchBooks(input.value), DEBOUNCE_DELAY_MS);

  input.addEventListener('input', debouncedSearch);

  input.addEventListener('keydown', e => {
    if (e.key === 'Enter') searchBooks(input.value);
  });

  searchBtn.addEventListener('click', () => searchBooks(input.value));
}

document.addEventListener('DOMContentLoaded', init);
