@extends('layouts.app')

@section('content')
@if(Auth::user()->is_sys_adm == 1)

    <div class="page-inner">
        <div class="main-card card">
            <div class="card-header">
                <h4 class="card-title">{{ $slide ? 'تعديل الشريحة' : 'إضافة شريحة جديدة' }}</h4>
            </div>
            <div class="card-body">
                <form id="slideForm" method="POST"
                      action="{{ $slide ? route('slider.update', $slide->id) : route('slider.store') }}"
                      enctype="multipart/form-data">
                    @csrf
                    @if($slide)
                        @method('PUT')
                    @endif

                    <div class="form-group">
                        <label for="name">اسم الشريحة *</label>
                        <input type="text" id="name" name="name" class="form-control @error('name') is-invalid @enderror" required
                               placeholder="أدخل اسم الشريحة" value="{{ old('name', $slide->name ?? '') }}">
                        @error('name')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>


                    <div class="form-group">
                        <label for="description">الوصف</label>
                        <textarea id="description" name="description" class="form-control"
                                  placeholder="أدخل وصف الشريحة">{{ old('description', $slide->description ?? '') }}</textarea>
                        @error('description')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label for="url">الرابط *</label>
                        <input type="url" id="url" name="url" class="form-control" 
                               placeholder="https://example.com/page" value="{{ old('url', $slide->url ?? '') }}">
                        @error('url')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label for="status">الحالة *</label>
                        <select id="status" name="status" class="form-control" required>
                            <option value="active" {{ (old('status', $slide->status ?? '') == 'active') ? 'selected' : '' }}>نشط</option>
                            <option value="inactive" {{ (old('status', $slide->status ?? '') == 'inactive') ? 'selected' : '' }}>غير نشط</option>
                        </select>
                        @error('status')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label for="image">صورة الشريحة {{ $slide ? '' : '*' }}</label>
                        <input type="file" id="image" name="image" class="form-control-file" {{ $slide ? '' : 'required' }}>
                        <small class="form-text text-muted">الصور المسموح بها: jpg, png. الحد الأقصى للحجم: 2MB</small>
                        @error('image')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="form-group">
                        <label>معاينة الصورة</label>
                        <div>
                            <img id="imagePreview"
                                 src="{{ old('image') ? '#' : ($slide ? $slide->image : asset('img/placeholder.png')) }}"
                                 alt="صورة الشريحة" style="max-width: 300px; max-height: 200px; display: block;">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-success">{{ $slide ? 'تحديث' : 'حفظ' }}</button>
                    <a href="{{ route('slider.index') }}" class="btn btn-secondary">إلغاء</a>
                </form>
            </div>
        </div>
    </div>


        <script>
            document.getElementById('image').addEventListener('change', function(event) {
                const [file] = event.target.files;
                if (file) {
                    const preview = document.getElementById('imagePreview');
                    preview.src = URL.createObjectURL(file);
                    preview.style.display = 'block';
                }
            });
        </script>

@endif
@endsection
