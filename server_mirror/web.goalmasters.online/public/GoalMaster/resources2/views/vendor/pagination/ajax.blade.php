<style>
  .pagination {
    display: flex;
    justify-content: center;
    list-style: none;
    padding: 0;
  }

  .pagination li {
    margin: 0 5px;
  }

  .pagination li a {
    text-decoration: none;
    padding: 5px 10px;
    border: 1px solid #007bff;
    border-radius: 4px;
    color: #007bff;
    background-color: #f8f9fa;
    transition: background-color 0.3s, color 0.3s, border-color 0.3s;
  }

  .pagination li.disabled span {
    padding: 5px 10px;
    color: #ccc;
    background-color: #e9ecef;
    border: 1px solid #dee2e6;
  }

  .pagination li.active span {
    padding: 5px 10px;
    background-color: #007bff;
    color: #fff;
    border: 1px solid #007bff;
    pointer-events: none;
  }

  @media (max-width: 600px) {
    .pagination {
      flex-wrap: wrap;
    }

    .pagination li {
      margin: 5px 2px;
    }

    .pagination li a,
    .pagination li span {
      padding: 8px 10px;
    }
  }
</style>

@if ($paginator->hasPages())
<ul class="pagination">
  {{-- Previous Page Link --}}
  @if ($paginator->onFirstPage())
  <li class="disabled"><span>&laquo;</span></li>
  @else
  <li><a href="{{ $paginator->previousPageUrl() }}" data-page="{{ $paginator->currentPage() - 1 }}">&laquo;</a></li>
  @endif

  {{-- Pagination Elements --}}
  @foreach ($elements as $element)
  @if (is_string($element))
  <li class="disabled"><span>{{ $element }}</span></li>
  @endif
  @if (is_array($element))
  @foreach ($element as $page => $url)
  @if ($page == $paginator->currentPage())
  <li class="active"><span>{{ $page }}</span></li>
  @else
  <li><a href="{{ $url }}" data-page="{{ $page }}">{{ $page }}</a></li>
  @endif
  @endforeach
  @endif
  @endforeach

  {{-- Next Page Link --}}
  @if ($paginator->hasMorePages())
  <li><a href="{{ $paginator->nextPageUrl() }}" data-page="{{ $paginator->currentPage() + 1 }}">&raquo;</a></li>
  @else
  <li class="disabled"><span>&raquo;</span></li>
  @endif
</ul>
@endif